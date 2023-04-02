project('kernel', 'd', version: '0.1.0')

dflags = [
  '-betterC',
]

add_project_arguments(dflags, language: 'd')
add_project_link_arguments(
  dflags + ['-static', '-Xcc=-nostdlib'],
  language: 'd')

inc = include_directories('..')
src = files(
  'console.d',
  'font.d',
  'framebuf.d',
  'graphics.d',
  'main.d',
  'mem.d',
  'paging.d',
  'support.d',
)

subdir('assets')

################################################################
##  normal
################################################################

nasm = generator(find_program('nasm'),
  arguments: ['-felf64', '@INPUT@', '-o', '@OUTPUT@'],
  output: '@BASENAME@.o')

ldflags = [
  '-L--entry=kernel_entry',
  '-L"--image-base 0x100000"',
]

kernel_x64 = executable('kernel_x64.elf', src, assets_x64,
  nasm.process('asm.s'),
  link_args: ldflags,
  include_directories: inc)
