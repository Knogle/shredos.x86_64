# Abruf des Commit-Hashes des nwipe Submoduls
nwipe_commit_hash=$(git -C ../../../external/nwipe rev-parse --short HEAD)

# Abruf des Branch-Namens des nwipe Submoduls
nwipe_branch=$(git -C ../../../external/nwipe rev-parse --abbrev-ref HEAD)

# Aktualisierung des Banners in version.c mit Branch-Name und Commit-Hash
sed -i "/banner/c\const char* banner = \"nwipe $nwipe_branch $nwipe_commit_hash\";" ./src/version.c

