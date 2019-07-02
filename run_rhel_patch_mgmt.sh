#!/bin/sh

DOM=`date +%d`
DOW=`date +%w`
LOG="/var/log/ansible/patch_run_`date +%Y-%m-%d`.log"
SETUP_LOG="/var/log/ansible/setup_patch_run_`date +%Y-%m-%d`.log"
SSH_KEY="-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAwaW4z3OTQm8Gx0aS2iYk9XeeFKFpGkHz8HT+W4u0O5nf86BH
fK860PtdPKhu85JOGllSwUUD4B6tQ/1cdiF075gnaRI3gjXlPqDItOzj4sEokDa9
sNQv6Fl51bxHMRU1E0nfrWwyBk+v+0GsZ306CBdKHznl31Xn62Rt7i0qxFBEsB0R
DgVfTsPDOvFk0AdJ51wD8GYlDm9fH8Xq2ZNgKfwzcv4E65mod0ga0YRx3nOl6raw
rkh4yzmJasIF+xBA1WPNfoATBCT9ryxByUL8qnQd/uKSal4i2phJQ8sL03i/0D6g
l7gZwVz0N7K4mWBLeqyq+1ftNTN1++GIjqgn4QIDAQABAoIBADIhetSJsQezwmd4
R7Ady9eYHd5tYs4fYM1RHEAKzJ/ZV/az+Y23t1w+loaLfB2mNH3xvdC20ygECQre
3j7erm0QULOMub4FwdESwqLD6MLdCmk7IqRSagyWjUndsfhs6w6RQ0ycA99KZd5/
w+gOrSVHEjM/Q9krXhy8JRFRtA6Z3cRVUGafz1PbzndcYtg74wyV/4dZIcGP2b84
a4MoGNFNqMlEHvL6nRQ+pWLVq4g+9cb4hLU180PicHB37U+xnuNaQUExS92OlMQs
Fgw+AkjHpyU1PGx5Eu0/wT+AzWrJvyc/LTz1i158dK5ceJQp1EE4J2nrxK7eCfpt
WtEFDxkCgYEA4WW1StppBjoigAPZ1vSu3tOpIXxPqnkjgd/LrQgvss+D9Egc6ZPc
g6C6Da+2bwE677q58CwiKfy0lgx0t9wxNMHSdLFrr0/xLkOgpWubOZ4gfyARdWl3
ze0VuitthTq1PygtQ/e/ytgUMZHz2MeLegwWd4l/w2V8jrXrCw40EYcCgYEA2/B1
Z1KpJOhm7G+ShsFxDekKnD0219pZfCavke4vYQrSoOZsA03wBexBzAvCRDNnCNiW
XOUX598+DsGcvKsYKlSNzpBiJGhjdNg0F13OK6nTm0vf2ID7lgwKM5tOkuKm7MTx
dNNZ7du8qAxdFViKLnww2ooHgOVAK56TVjRQ9VcCgYBHGlCgdlnfLwOnIo/bsYBg
pqCaAZ8YBfLfi3uy7/wsCi50JzOHs69CjrdijeWdCuROr7bsPt/gIunM080WGw4i
uGntifKQcUWB9K9+v31OJcXWlIUtZsH2Yi4SdpSsDKMUc1YkNMl58cQdBw/HeNtU
+u8zclqthxxN4LFu4WInjQKBgF6YJjahM8R+/D12o0O4EULVV03pehwOemxOSzbt
hY0sVXkEgbJOJAy4F3iGGjCxFwCT/t/HXKfKuWspVJtEzyjtouwT51IXX6dSkdz2
6ISZDzz8vjLlDs/zL7QQeRPtzbOJ5PvFJymJV7PDVYmnwg7KNUzZDu8eKqJYGrB5
4dQTAoGBAKs+mWbIrbpUvMGJFVDs5LDek+yHv0IlDrbeqE+7nS1X9knE/xHYepmc
KRTFv+OPewta4DeZtxpoXcw2UV9Kgp0VxJl/BQDOS7MHZ2KSefmmKZCWwNlOSmr5
GAZmd1juFrhuaw7yCFAUqLydJNlE11vPa/ysloU/gxOPYrdIzFyx
-----END RSA PRIVATE KEY-----"
PLAYBOOK="/path/to/patch_rhel.yml"
CREATEVARS="/path/to/ansible/roles/rhel-patchmanagement/create_vars.sh"

# Run Patch-Management ad-hoc in the specified stage
# Example: './run_rhel_patch_mgmt.sh NOW rhel-patch-phase1'
if [ "${1}" = "NOW" ] && [ -n "${2}" ]
then
  ansible-playbook $PLAYBOOK --private-key=$SSH_KEY --limit="${2}" >> $LOG 2>&1
  exit
fi

if [ "${1}" = "NOW" ] && [ -z "${2}" ]
then
  echo "ERROR: Second argument is missing."
  echo "Example: './run_rhel_patch_mgmt.sh NOW rhel-patch-phase1'"
  exit
fi

# Setup the next patchcycle
if [ "$DOW" = "2" ] && [ "$DOM" -gt 0 ] && [ "$DOM" -lt 8 ]
then
    $CREATEVARS > $SETUP_LOG 2>&1
fi

# Patchcycle of the rhel-patch-phase1 on the second Tuesday of a month
if [ "$DOW" = "2" ] && [ "$DOM" -gt 7 ] && [ "$DOM" -lt 15 ]
then
    ansible-playbook $PLAYBOOK --private-key=$SSH_KEY --limit=rhel-patch-phase1 > $LOG 2>&1
fi

# Patchcycle of the rhel-patch-phase2 on the third Tuesday of a month
if [ "$DOW" = "2" ] && [ "$DOM" -gt 14 ] && [ "$DOM" -lt 22 ]
then
    ansible-playbook $PLAYBOOK --private-key=$SSH_KEY --limit=rhel-patch-phase2 > $LOG 2>&1
fi

# Patchcycle of the rhel-patch-phase3 on the fourth Tuesday of a month
if [ "$DOW" = "2" ] && [ "$DOM" -gt 21 ] && [ "$DOM" -lt 29 ]
then
    ansible-playbook $PLAYBOOK --private-key=$SSH_KEY --limit=rhel-patch-phase3 > $LOG 2>&1
fi

# Patchcycle of the rhel-patch-phase4 on the fourth Wednesday of a month
if [ "$DOW" = "3" ] && [ "$DOM" -gt 21 ] && [ "$DOM" -lt 30 ]
then
    ansible-playbook $PLAYBOOK --private-key=$SSH_KEY --limit=rhel-patch-phase4 > $LOG 2>&1
fi
