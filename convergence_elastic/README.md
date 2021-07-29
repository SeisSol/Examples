## Elastic Convergence Runner

### Dependencies

- SeisSol and its software stack
- cubeGenerator (see, [source code](https://github.com/SeisSol/SeisSol/tree/master/preprocessing/meshing/cube_c))

### Installing
```python
pip3 install -r requirements.txt
```

### Running
Example:
```python
PYTHONPATH=$PWD python3 \
./elastic_convergence_runner \
--executable <path to SeisSol executable> \
--tmp-dir <temporary directory> \
--sizes 4 8 16 \
--expected-errors 1e-2 1e-4 5e-5 \
--norm-type LInf \
--end-time 0.1
```

### Artifacts
Runner creates an error log-log plot which can be found in `<temporary directory>/<norm type>.png`.
You can change the plot name using `--output-filename` command line argument