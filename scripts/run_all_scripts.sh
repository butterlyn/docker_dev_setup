for script in ${SCRIPT_PATH}/*.sh
do
    echo -e "Executing script:\n${script}\n"
    if ! bash "$script"; then
        echo "Error: Failed to execute $script" >&2
        exit 1
    fi
done
