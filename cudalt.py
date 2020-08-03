#!/usr/bin/env python3
# libtoolish hack: compile a .cu file like libtool does
import os
import subprocess
import sys


def execute(cmd_base, args):
    cmd = ' '.join([cmd_base, *args])
    print(cmd)
    subprocess.run(cmd, shell=True, check=True)


def get_libtool_version():
    proc = subprocess.run(['libtool', '--version'],
                          capture_output=True, check=True)
    return str(proc.stdout.splitlines()[0], 'ascii')


def main(argv):
    lo_filepath = argv[0]
    cmd_base = ' '.join(argv[1:])

    o_filepath = lo_filepath.replace('.lo', '.o')

    try:
        i = o_filepath.rindex('/')
        lo_dir = o_filepath[0:i + 1]
        o_filename = o_filepath[i + 1:]

    except ValueError:
        lo_dir = ''
        o_filename = o_filepath

    local_pic_dir = '.libs/'
    local_npic_dir = ''
    pic_dir = lo_dir + local_pic_dir
    npic_dir = lo_dir + local_npic_dir

    pic_filepath = pic_dir + o_filename
    npic_filepath = npic_dir + o_filename
    local_pic_filepath = local_pic_dir + o_filename
    local_npic_filepath = local_npic_dir + o_filename

    # Make lib dir
    try:
        os.mkdir(pic_dir)
    except OSError:
        pass

    try:
        # compile the .cu for shared library
        execute(cmd_base, [
            '-Xcompiler',
            '-fPIC',
            '-o',
            pic_filepath,
        ])
        # compile the .cu for static library
        execute(cmd_base, [
            '-o',
            npic_filepath,
        ])

        libtool_version = get_libtool_version()
    except subprocess.CalledProcessError:
        return 1

    # generate the .lo file
    with open(lo_filepath, 'w') as fp:
        print("# " + lo_filepath + " - a libtool object file", file=fp)
        print("# Generated by " + libtool_version + "", file=fp)
        print("#", file=fp)
        print("# Please DO NOT delete this file!", file=fp)
        print("# It is necessary for linking the library.", file=fp)

        print("# Name of the PIC object.", file=fp)
        print("pic_object='" + local_pic_filepath + "'", file=fp)

        print("# Name of the non-PIC object.", file=fp)
        print("non_pic_object='" + local_npic_filepath + "'", file=fp)

    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
