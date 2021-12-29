path = "/path/to/a/google/takeout/directory"

defmodule JsonArchiver do
  def call(path) do
    path
    |> get_json_files()
    |> maybe_archive_json_files()
  end

  defp get_json_files(path) do
    "find"
    |> System.cmd([path, "-type", "f", "-maxdepth", "1", "-name", "\*.json"])
    |> elem(0)
    |> String.split("\n")
    |> Enum.reject(fn filename -> filename == "" end)
  end

  defp maybe_archive_json_files(files) do
    case length(files) do
      0 -> {:ok, "Skipped. No json files found to archive"}
      _ -> archive_json_files(files)
    end
  end

  defp archive_json_files(files) do
    IO.inspect "Archiving #{length(files)} json files"

    target_directory = get_json_archive_directory(files)

    :ok = File.mkdir_p(target_directory)

    move_json_files(target_directory, files)
  end

  defp get_base_directory(files) do
    files
    |> List.first()
    |> String.split("/")
    |> Enum.reverse()
    |> tl()
    |> Enum.reverse()
    |> Enum.join("/")
  end

  defp get_json_archive_directory(files) do
    get_base_directory(files) <> "/json"
  end

  defp move_json_files(target_directory, files) do
    Enum.map(files, fn path ->
      filename = get_filename(path)

      :ok = File.rename(path, "#{target_directory}/#{filename}")
    end)
  end

  defp get_filename(path) do
    path
    |> String.split("/")
    |> List.last()
  end
end

defmodule PhotoGrouper do
  @size 1000

  def call(path) do
    path
    |> get_files()
    |> maybe_group_files()
  end

  defp get_files(path) do
    "find"
    |> System.cmd([path, "-type", "f", "-maxdepth", "1"])
    |> elem(0)
    |> String.split("\n")
    |> Enum.reject(fn filename -> filename == "" end)
    |> Enum.sort()
  end

  defp maybe_group_files(files) do
    case length(files) do
      0 -> {:ok, "Skipped. No files to group"}
      _ -> group_files(files)
    end
  end

  defp group_files(files) do
    files
    |> Enum.chunk_every(@size)
    |> Enum.with_index(fn chunk, index ->
      IO.inspect "Grouping chunk #{index}"

      target_directory = get_target_directory(files, index+1)

      :ok = File.mkdir_p(target_directory)

      move_chunk_files(target_directory, chunk)
    end)
  end

  defp get_base_directory(files) do
    files
    |> List.first()
    |> String.split("/")
    |> Enum.reverse()
    |> tl()
    |> Enum.reverse()
    |> Enum.join("/")
  end

  defp get_target_directory(files, index) do
    name =
      index
      |> Integer.to_string()
      |> String.pad_leading(3, "0")

    "#{get_base_directory(files)}/#{name}"
  end

  defp move_chunk_files(target_directory, chunk) do
    Enum.map(chunk, fn path ->
      filename = get_filename(path)

      :ok = File.rename(path, "#{target_directory}/#{filename}")
    end)
  end

  defp get_filename(path) do
    path
    |> String.split("/")
    |> List.last()
  end
end

JsonArchiver.call(path)
PhotoGrouper.call(path)
