opm alpha bundle generate --directory ./prom_0.22 --package test-operator --channels beta --default beta
docker build -t {registry}/my-manifest-bundle:0.0.1 -f bundle.Dockerfile .
docker push {registry}/my-manifest-bundle:0.0.1

opm index add --bundles {registry}/my-manifest-bundle:0.0.1 --tag {regsitry}/my-index:1.0.0 -c="docker"
docker push {registry}/my-index:1.0.0
