kubectl -n beyond delete cm timezone
kubectl -n beyond create cm timezone --from-file=timezone
