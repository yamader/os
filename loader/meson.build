project('loader', 'd', version: '0.1.0')

if meson.get_compiler('d').get_id() != 'llvm'
  warning('ldcじゃないと動かないよ!多分!')
endif

dflags = [
  '-betterC',
]

add_project_arguments(dflags, language: 'd')
add_project_link_arguments(
  dflags + ['-static', '-Xcc=-nostdlib'],
  language: 'd')

inc = include_directories('..')
src = files(
  'efi.d',
  'main.d',
  'memmap.d',
)

################################################################
##  UEFI
################################################################

ldflags_efi = [
  '-Xcc=-Wl,/subsystem:efi_application',
  '-Xcc=-Wl,/entry:UefiMain',
]

# x64
triple = 'x86_64-unknown-windows'
loader_efi_x64 = executable('bootx64.efi', src,
  d_args: f'--mtriple=@triple@',
  link_args: ldflags_efi + [
    f'--mtriple=x86_64', # 魔法
    '--gcc=clang',
    f'-Xcc=--target=@triple@'],
  include_directories: inc)
