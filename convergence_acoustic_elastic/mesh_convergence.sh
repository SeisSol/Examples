#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

upper_limit=1 # set maximum mesh size
declare -ar scenarios=(snell scholte ocean)

if [ "$#" -ne 2 ]; then
    echo "Pass two arguments. First scenario name = ${scenarios[@]}, second = maximum refinement level"
fi

declare -r scenario=${1}
declare -ri upper_limit=${2}

if [[ ! " ${scenarios[@]} " =~ " ${scenario} " ]]; then
    echo "$scenario is not a valid scenario! They are: ${scenarios[@]}"
    exit 1
fi

echo "Meshing $scenario for levels up to $upper_limit."

mkdir -p meshes

declare -r scenario_dir="convergence_${scenario}/"
declare -r template_name="${scenario_dir}/mesh_template.geo"
mkdir -p "${scenario_dir}/meshes"
for ((i=1; i<=${upper_limit}; i++)) ; do
    declare output_name="${scenario_dir}/meshes/mesh_${i}.geo"

    factor=${i} envsubst < "${template_name}" > "$output_name"

    output_name=$(readlink -e -- "$output_name")
    output_name="${output_name%.*}" # strip extension

    # Assumes gmsh, gmsh2gambit and pumgen are in $PATH
    gmsh -3 -nt 5 -cpu -format msh2 "${output_name}.geo" 
    pumgen -s msh2 "${output_name}.msh" "${output_name}.h5"
    rm -rf "${output_name}.msh" "${output_name}.neu"
done


exit 0
