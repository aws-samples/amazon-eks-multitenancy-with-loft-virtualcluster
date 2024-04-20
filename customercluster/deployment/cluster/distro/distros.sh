# ************************************************************
# **********vcluster with different distro*******************
# ************************************************************

k create ns v-k0s

vcluster create k0s-vcluster --namespace v-k0s --distro k0s --update-current=false 