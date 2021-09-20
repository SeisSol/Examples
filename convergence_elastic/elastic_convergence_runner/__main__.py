from elastic_convergence_runner.runner import Runner
import argparse
import matplotlib.pyplot as plt
import os
import pandas as pd


def main():
  parser = argparse.ArgumentParser(description='runs seissol elastic convergence tests')
  parser.add_argument('-e', '--executable', type=str, help='SeisSol executable')
  parser.add_argument('--tmp-dir', type=str, default='/tmp', help='path to tmp dir.')
  parser.add_argument('--verbose', action='store_true', help='print verbose information')
  parser.add_argument('--sizes', nargs='+', type=int, default=[4, 8])
  parser.add_argument("--norm-type",
                      type=str,
                      choices=['L1', 'L2', 'LInf', 'L1_rel', 'L2_rel', 'LInf_rel'],
                      default='LInf',
                      help="norm type")
  parser.add_argument('--expected-errors', nargs='+', type=float, default=[1e-2, 1e-4])
  parser.add_argument('--end-time', type=float, default=2.0, help='end simulation time')
  parser.add_argument('--allow-run-as-root', action='store_true', help='allow to run MPI as root')
  args = parser.parse_args()
  
  if len(args.sizes) != len(args.expected_errors):
    raise RuntimeError('`sizes` and `expected_errors` must have the same size')
  
  if args.end_time <= 0.0:
    raise RuntimeError(f'end time must be greater than zero, given {args.end_time}')

  runner = Runner(seissol_exe=args.executable,
                  end_time=args.end_time,
                  tmp_dir=args.tmp_dir,
                  allow_to_run_as_root=args.allow_run_as_root,
                  verbose=args.verbose)
  
  data = runner.run_all(args.sizes)
  processed_data = {'sizes': [], 'errors': []}
  try:
    for expected_error, experiment in zip(args.expected_errors, data):
      for size, results in experiment.items():
        max_obtained_error = get_max_obtained_error(results, args.norm_type)
        if expected_error > max_obtained_error:
          processed_data['sizes'].append(size)
          processed_data['errors'].append(max_obtained_error)
        else:
          raise RuntimeError(f'at `size` {size}, {max_obtained_error} > {expected_error}')
  except RuntimeError as err:
    print_all_collected_data(data)
    print(err)
    raise err

  processed_data = pd.DataFrame.from_dict(processed_data)
  print(processed_data)
  processed_data.plot.line(x='sizes', y='errors', loglog=True, style='.-', ms=14)
  plt.savefig(f'{os.path.join(args.tmp_dir, args.norm_type)}.png',
              bbox_inches='tight',
              dpi=300)


def get_max_obtained_error(results, norm_type):
  max_item = results[results['norm'] == norm_type].max()
  return max_item['error']


def print_all_collected_data(data):
  bar = '*' * 80
  whitespaces = ' ' * 35

  for experiment in data:
    for size, results in experiment.items():
      print(bar)
      print(f'{whitespaces} SIZE {size}')
      print(bar)

      for norm_type in results['norm'].unique():
        filtered = results[results['norm'] == norm_type]
        print(filtered[['variable', 'error']])


if __name__ == '__main__':
  main()
