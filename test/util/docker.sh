
util_dir="$(dirname $(readlink -f $BASH_SOURCE))"
hookit_dir="$(readlink -f ${util_dir}/../../src)"
payloads_dir=$(readlink -f ${util_dir}/../payloads)

payload() {
  cat ${payloads_dir}/${1}.json
}

run_hook() {
  hook=$1
  payload=$2

  docker exec \
    code \
    /opt/microbox/hooks/$hook "$payload"
}

start_container() {
  docker run \
    --name=code \
    -d \
    -e "PATH=$(path)" \
    --privileged \
    --net=microbox \
    --ip=192.168.0.2 \
    --volume=${hookit_dir}/:/opt/microbox/hooks \
    mubox/code
}

restart_container() {
  docker restart code
}

stop_container() {
  docker stop code
  docker rm code
}

path() {
  paths=(
    "/opt/gomicro/sbin"
    "/opt/gomicro/bin"
    "/opt/gomicro/bin"
    "/usr/local/sbin"
    "/usr/local/bin"
    "/usr/sbin"
    "/usr/bin"
    "/sbin"
    "/bin"
  )

  path=""

  for dir in ${paths[@]}; do
    if [[ "$path" != "" ]]; then
      path="${path}:"
    fi

    path="${path}${dir}"
  done

  echo $path
}
