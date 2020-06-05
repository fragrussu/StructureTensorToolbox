# StructureTensorToolbox
2D Structure tensor (ST) analysis toolbox for MATLAB.

The toolbox provides a collection of routines for the evaluation of directional statistics and staining fraction metrics via patch-wise analysis of histological images. The toolbox is specifically designed for the quantification of *orientation dispersion* in histological images of neural tissue, as for example silver-stained 2D sagittal sections of spinal cord specimens as done in [this paper of ours](http://doi.org/10.1002/acn3.445). 

Tutorials are available within the [*examples*](https://github.com/fragrussu/StructureTensorToolbox/tree/master/examples) folder:
* [*example01_STanalysis.m*](https://github.com/fragrussu/StructureTensorToolbox/blob/master/examples/example01_STanalysis.m) shows how to perform ST analysis and how to extract directional statistics within image pages;
* [*example02_kmeans.m*](https://github.com/fragrussu/StructureTensorToolbox/blob/master/examples/example02_kmeans.m) shows how to perform basic segmentation of stained histological material based on k-means clustering in RGB colour space.

# License information 
StructureTensorToolbox is released under the BSD Two-Clause License (see [LICENSE.md](https://github.com/fragrussu/StructureTensorToolbox/blob/master/LICENSE.md) of [LICENSE.pdf](https://github.com/fragrussu/StructureTensorToolbox/blob/master/LICENSE.pdf)).

Each contributor holds copyright over his/her own contributions to the software. The project versioning records all contributions and copyright details. 
By contributing to the software, the contributor releases his/her content according to the license and copyright terms of StructureTensorToolbox.

# Acknowledgement
If you use StructureTensorToolbox for your research, please cite:

"Neurite dispersion: a new marker of multiple sclerosis spinal cord pathology?". Grussu F, Schneider T, Tur C, Yates RL, Tachrount M, Ianus A, Yiannakas MC, Newcombe J, Zhang H, Alexander DC, DeLuca GC and Gandini Wheeler-Kingshott CAM. Annals of Clinical and Translational Neurology (2017): vol. 4(9), pages 663–679. DOI: 10.1002/acn3.445. Link to paper [here](http://doi.org/10.1002/acn3.445).

"A framework for optimal whole-sample histological quantification of neurite orientation dispersion in the human spinal cord". Grussu F,  Schneider T,  Yates RL,  Zhang H,  Gandini Wheeler-Kingshott CAM, DeLuca GC and Alexander DC. Journal of Neuroscience Methods (2016): vol. 273, pages 20–32. DOI: 10.1016/j.jneumeth.2016.08.002. Link to paper [here](http://doi.org/10.1016/j.jneumeth.2016.08.002).

