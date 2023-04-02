objcopy = find_program('llvm-objcopy', 'objcopy')

################################################################
##  font
################################################################

bdf2bin = generator(find_program('../../scripts/bdf2bin.d'),
  output: '@BASENAME@.bin',
  arguments: ['@INPUT@', '@OUTPUT@'])

# terminus
terminus_bin = bdf2bin.process('ter-u16b.bdf')
terminus_x64 = custom_target('terminus_x64',
  input: terminus_bin,
  output: '@BASENAME@.o',
  command: [objcopy, '-Ibinary', '-Oelf64-x86-64',
    '--redefine-sym=_binary_assets_ter_u16b_o_p_ter_u16b_bin_start=ter_u16b',
    '@INPUT@', '@OUTPUT@'])

################################################################
##  all
################################################################

assets_x64 = [
  terminus_x64,
]
