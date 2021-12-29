# About

> A collection of tools for managing Google Takeout files

## Google Photo Preprocessor

The preprocessor:

- Moves metadata files like `json` into their own directory
- Chunks image and video files into separate directories

These actions make it easier to import into tools - like Apple Photos - that
would otherwise have difficulty processing the large volume of photos in their
default state.

### Usage

First open the file and update the path variable at the top of this file:

  path = "/path/to/Takeout/Google\ Photos/Photos\ from\ 2020"

Then execute from a command line:

  $ elixir -r photo-preprocessor.ex

#### Note

This kind of preprocessing is only really needed for directories with
large number of files in them. Specify one directory at a time
