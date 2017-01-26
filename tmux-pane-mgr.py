#
# WARNING: This scripts does not work as it turns our tmux is not labelling
# its pane with consistent ids. Pane ids will change over time as you create
# new panes in your winwdow.
#

#!/usr/bin/python
import argparse
import subprocess


def check_call(*args, **kwargs):
  print args, kwargs
  subprocess.check_call(*args, **kwargs)


g_tmux_exec = 'tmux'
g_list_pane_cmd = [r'list-pane', r'-F', r'#{pane_top} #{pane_left} #{pane_current_path}']
g_select_pane_cmd = ['select-pane', '-t']
g_split_horizontally_cmd = ['split-window', '-h', '-l']
g_split_vertically_cmd = ['split-window', '-l']


def dump(filepath):
  with open(filepath, "w") as outfile:
    check_call([g_tmux_exec] + g_list_pane_cmd, stdout=outfile)


def read(filepath):
  with open(filepath, "r") as infile:
    panes = [{
      'index': index,
      'top': line.strip().split(' ')[0],
      'left': line.strip().split(' ')[1],
      'wd': line.strip().split(' ')[2]
    } for (index, line) in enumerate(infile.readlines())]
    print 'panes', panes
    for pane in panes[1:]:
      # search through parent, the pane with a common coordinate
      print "on pane", pane['index']
      print "parent", panes[0:pane['index']]
      for parentPane in panes[0:pane['index']]:
        print 'parentPane:', parentPane
        if pane['top'] == parentPane['top']:
          # position the focus on the parentPane
          check_call([g_tmux_exec] + g_select_pane_cmd + [str(parentPane['index'])])
          # create a horizontal split
          check_call([g_tmux_exec] + g_split_horizontally_cmd + [pane['left']])
          # change working directory
          #check_call(['cd', parentPane['wd']])
          break
        elif pane['left'] == parentPane['left']:
          # position the focus on the parentPane
          check_call([g_tmux_exec] + g_select_pane_cmd + [str(parentPane['index'])])
          # create a horizontal split
          check_call([g_tmux_exec] + g_split_vertically_cmd + [pane['top']])
          # change working directory
          #check_call(['cd', parentPane['wd']])
          break


parser = argparse.ArgumentParser(description='Dump or recreate tmux pane layouts.')
parser.add_argument('-r', '--read', metavar=('filepath',), type=str, nargs=1,
                    help='file to read')
parser.add_argument('-d', '--dump', metavar=('filepath',), type=str, nargs=1,
                    help='file to write')

if __name__ == '__main__':
  args = parser.parse_args()
  options = vars(args)
  if options['read'] and options['dump']:
    print('Error: either dumps or reads, not both')
    parser.print_help()
    exit(1)

  if options['read'] is not None:
    read(options['read'][0])
    exit(0)

  if options['dump'] is not None:
    dump(options['dump'][0])
    exit(0)

  print('Error: no argument provided')
  parser.print_help()
  exit(1)

