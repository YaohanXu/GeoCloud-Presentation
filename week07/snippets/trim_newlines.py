

filename = '...'
with open(filename, 'rb+') as f:

    # Go to the end of the file, and back up one byte
    f.seek(-1, 2)

    # Check whether the last byte is a newline (\n or \r)
    last_byte = f.peek(1)
    while last_byte in (b'\n', b'\r'):

        # If it is, trim it off
        print(f'Trimming {last_byte!r} from end of file')
        f.truncate()

        # Go back one more byte and check again
        f.seek(-1, 1)
        last_byte = f.peek(1)
