#!/bin/bash

# Scripts a mantener
declare -a scripts_to_keep=(
    "test_login.sh"
    "test_roles.sh"
    "test_endpoints.sh"
)

# Documentación a mantener
declare -a docs_to_keep=(
    "README.md"
)

# Limpiar scripts
for script in $(ls scripts/*.sql scripts/*.js scripts/update_*); do
    keep=false
    for keep_script in "${scripts_to_keep[@]}"; do
        if [[ "$script" == *"$keep_script" ]]; then
            keep=true
            break
        fi
    done
    if [ "$keep" = false ]; then
        rm -f "$script"
    fi
done

echo "Limpiando completado. Archivos mantenidos:"
echo "Scripts: ${scripts_to_keep[*]}"
echo "Documentación: ${docs_to_keep[*]}"
