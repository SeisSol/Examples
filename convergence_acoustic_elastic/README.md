# Elastic-Acoustic Convergence Tests
You can create meshes by running the script mesh\_convergence.
You have to pass two arguments. The first is the scenario name (snell, scholte or ocean), the second is the maximum desired refinement level.

## Scholte waves
As described in: Wilcox, Lucas C., Georg Stadler, Carsten Burstedde, and Omar Ghattas. “A High-Order Discontinuous Galerkin Method for Wave Propagation through Coupled Elastic–Acoustic Media.” Journal of Computational Physics 229, no. 24 (December 2010): 9373–96. https://doi.org/10.1016/j.jcp.2010.09.008.

The setup is contained in the directory convergence\_scholte.
Scholte waves are waves that propagate along elastic–acoustic interfaces.
This test cases tests wave propagation (acoustic, elastic) and the elastic-acoustic interface.

## Snell's law
As described in: Wilcox, Lucas C., Georg Stadler, Carsten Burstedde, and Omar Ghattas. “A High-Order Discontinuous Galerkin Method for Wave Propagation through Coupled Elastic–Acoustic Media.” Journal of Computational Physics 229, no. 24 (December 2010): 9373–96. https://doi.org/10.1016/j.jcp.2010.09.008.

The setup is contained in the directory convergence\_snell.
It describes a pressure plane wave incident on an acoustic–elastic interface.
This incident wave in the acoustic medium gets transmitted as longitudinal and transverse waves in the elastic medium and it gets reflected as a pressure wave.
This test cases tests wave propagation (acoustic, elastic) and the elastic-acoustic interface.


## Water tank model
Currently unpublished verification test.
Discussed in AGU abstract: Abrahams, L. S., Krenz, L., Dunham, E. M., & Gabriel, A. A. (2019, December). Verification of a 3D fully-coupled earthquake and tsunami model. In AGU Fall Meeting Abstracts (Vol. 2019, pp. NH43F-1000).

It is a 3D version of the 2D test case published in:
Lotto, Gabriel C., and Eric M. Dunham. “High-Order Finite Difference Modeling of Tsunami Generation in a Compressible Ocean from Offshore Earthquakes.” Computational Geosciences 19, no. 2 (April 2015): 327–40. https://doi.org/10.1007/s10596-015-9472-0.

The setup is contained in the directory convergence\_ocean.
It describes wave modes in the ocean.
There are three different versions of this scenario, which can be selected by modifying the parameters.par file.
The zeroth mode (gravity) is selected by setting cICType = 'Ocean\_0', the first and second (acoustic) modes by setting it to Ocean\_1 or Ocean\_2.
This setup tests acoustic wave propagation and the gravitational free surface boundary condition.
