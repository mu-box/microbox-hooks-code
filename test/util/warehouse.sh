# utilities and helpers for launching a warehouse for data storage

util_dir="$(dirname $(readlink -f $BASH_SOURCE))"
tarballs_dir=$(readlink -f ${util_dir}/../tarballs)

start_warehouse() {
  # launch container
  docker run \
    --name=warehouse \
    -d \
    --privileged \
    --net=nanobox \
    --ip=192.168.0.100 \
    --volume=${tarballs_dir}/:/tarballs \
    nanobox/hoarder

  # configure
  docker exec \
    warehouse \
    /opt/nanobox/hooks/configure "$(warehouse_configure_payload)"

  # start
  docker exec \
    warehouse \
    /opt/nanobox/hooks/start "$(warehouse_start_payload)"

  # upload tarballs
  docker exec \
    warehouse \
    bash -c '
      cat /tarballs/deploy-123.tgz \
        | curl \
            -k \
            -H "x-auth-token: 123" \
            https://127.0.0.1:7410/blobs/deploy-123.tgz \
            --data-binary @-'

  docker exec \
    warehouse \
    bash -c '
      cat /tarballs/app-123.tgz \
        | curl \
            -k \
            -H "x-auth-token: 123" \
            https://127.0.0.1:7410/blobs/app-123.tgz \
            --data-binary @-'
}

stop_warehouse() {
  # destroy container
  docker stop warehouse
  docker rm warehouse
}

warehouse_configure_payload() {
  cat <<-END
{
  "logvac_host": "192.168.0.102",
  "platform": "production",
  "config": {
    "token": "123"
  },
  "member": {
    "local_ip": "192.168.0.100",
    "uid": 1,
    "role": "primary"
  },
  "component": {
    "name": "willy-walrus",
    "uid": "hoarder1",
    "id": "9097d0a7-7e02-4be5-bce1-3d7cb1189488"
  },
  "ssh": {
    "admin_key": {
      "private_key": "-----BEGIN RSA PRIVATE KEY-----\nMIIBzQIBAAJhAMfGROoEU7uwou1T2vsNMSDk6hB0eLGT+ngICJio/UZh2u1oCLow\nLAMjgCPW3/7dtoPdioYZr/u5Hi7OPILzapZF218mrCcJMwH1kO/28Ne7rVn7tWgq\nO3Mgtm5AbFtfCQIDAQABAmEAhWqsa30oTpjQtp7iB/fvb4BxsTuXv0CMbc0vsIRr\nYa3If/SSn4W8Xvw+f7DpN1TpeJyNkVNaP8L7lE6n65Km9vQ3cPT5uz8SYrJZDrWG\nNYT4pAcRi/aOgdMkQk7JP0HhAjEA8yF57NdqnYp/UCSV5mFj4f3bgf+crMGc+fKv\nHGFrXtcv8EFwIXLO74LQaejwX+H7AjEA0llMFXyZk1qt5Ot2cwz7LxeUNiwZKY71\nPjc4ervos105dwSvMiyTuUccN5uvvvfLAjEAneqFbd7xAch+LsjEkDF7lcKz+3jS\nA6dx1SrasB1ahuxP18Y5FZCjdg/KXLAOyMhXAjEAi0F44ESz+1yuAP5tVW+Dn0KR\n6Wc6ZUvySfUO3BoozQ3rrEKapbHjPma4ZIwaRmgPAjEAqo/K6QAstxCdvk5D6w0o\nfijJ3f8mQoa3DfJEukvCd1nz5zwjzneox2m5qqP1yehr\n-----END RSA PRIVATE KEY-----",
      "public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAYQDHxkTqBFO7sKLtU9r7DTEg5OoQdHixk/p4CAiYqP1GYdrtaAi6MCwDI4Aj1t/+3baD3YqGGa/7uR4uzjyC82qWRdtfJqwnCTMB9ZDv9vDXu61Z+7VoKjtzILZuQGxbXwk= root"
    }
  },
  "users": [

  ]
}
END
}

warehouse_start_payload() {
  cat <<-END
{
  "config": {
    "token": "123"
  }
}
END
}
