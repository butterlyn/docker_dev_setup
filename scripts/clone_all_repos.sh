# GITHUB_USERNAME takes the value of the environment variable GITHUB_USERNAME

# Test if the environment variable has been set
if [ -z "$GITHUB_USERNAME" ]; then
    GITHUB_USERNAME=butterlyn
fi

# Ensure the repos directory exists
mkdir -p ./repos

# Get list of all repositories for the given user
repo_names=$(curl -s "https://api.github.com/users/$GITHUB_USERNAME/repos" | jq -r '.[].name')

# Loop over all repository names and clone
for repo_name in $repo_names; do
    git clone "https://github.com/$GITHUB_USERNAME/$repo_name.git" "./repos/$repo_name"
done

