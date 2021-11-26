#!/usr/bin/bash

ENV_FILE=".env"
export $(grep -v '^#' $ENV_FILE | sed 's/#.*\]//g' |  xargs)

postgres_run_environments=" -e POSTGRES_USER=$POSTGRES_RUN_ENVIRONMENT_USERNAME \
                             -e POSTGRES_PASSWORD=$POSTGRES_RUN_ENVIRONMENT_PASSWORD \
                             -e POSTGRES_DB=$POSTGRES_RUN_ENVIRONMENT_DATABASE"

function build()
{
  case $1 in 
    'nodejs')
    if [ $(docker image list | grep -w $NODE_IMAGE_NAME | grep -w $NODE_IMAGE_TAG | wc -l) == '1' ]; then
      delete=$(docker image remove --force $NODE_IMAGE_NAME)
      echo "### Message ### -> Image $NODE_IMAGE_NAME:$NODE_IMAGE_TAG deleted!"
    fi
    if [ $NODE_IMAGE_MODE == 'BUILD' ]; then
      docker build --no-cache -t $NODE_IMAGE_NAME:$NODE_IMAGE_TAG $NODE_DOCKERFILE
      echo "### Message ### -> $NODE_IMAGE_NAME:$NODE_IMAGE_TAG image generated!"
    else
      docker pull $NODE_IMAGE_NAME:$NODE_IMAGE_TAG
      echo "### Message ### -> $NODE_IMAGE_NAME:$NODE_IMAGE_TAG image downloaded!"
    fi
    ;;
    'postgres')
    if [ $(docker image list | grep -w $POSTGRES_IMAGE_NAME | grep -w $POSTGRES_IMAGE_TAG | wc -l) == '1' ]; then
      delete=$(docker image remove --force $POSTGRES_IMAGE_NAME 2>&1)
      echo "### Message ### -> Image $POSTGRES_IMAGE_NAME:$POSTGRES_IMAGE_TAG deleted!"
    fi
    if [ $POSTGRES_IMAGE_MODE == 'BUILD' ]; then
      echo build
      docker build --no-cache -t $POSTGRES_IMAGE_NAME:$POSTGRES_IMAGE_TAG $POSTGRES_DOCKERFILE
      echo "### Message ### -> $POSTGRES_IMAGE_NAME:$POSTGRES_IMAGE_TAG image generated!"
    else
      docker pull $POSTGRES_IMAGE_NAME:$POSTGRES_IMAGE_TAG
      echo "### Message ### -> $POSTGRES_IMAGE_NAME:$POSTGRES_IMAGE_TAG image downloaded!"
    fi
    ;;
  esac
}

function delete_image()
{
  if [ $(docker image list | grep -w $1 | grep -w $2 | wc -l) == '1' ]; then
    delete=$(docker image rm --force $1:$2)
    echo "### Message ### -> Image $1:$2 deleted!"
  fi
}

function delete_container()
{
  if [ $(docker ps -a | grep -w $1 | wc -l) == '1' ]; then
    delete=$(docker rm -f $1)
    echo "### Message ### -> Container $1 deleted!"
  fi
}

function run()
{
  case $1 in 
    "nodejs") #nodejs
      #Build if not image exists
      if [ $(docker image list | grep -w $NODE_IMAGE_NAME | grep -w $NODE_IMAGE_TAG | wc -l) == '0' ]; then
        build nodejs
      fi
      #Run dependencies
      if [ $NODE_RUN_DEPENDENCIES != "" ]; then
        run $NODE_RUN_DEPENDENCIES
      fi
      #Delete container if exists
      if [ $(docker ps -a | grep -w $NODE_RUN_NAME | wc -l) == '1' ];then
        delete=$(docker rm -f $NODE_RUN_NAME)
        echo "### Message ### -> Container $NODE_RUN_NAME deleted!"
      fi
      #Create network if not exists
      if [ $(docker network list | grep -w $GLOBAL_NETWORK | wc -l) == '0' ]; then
        createNetwork=$(docker network create $GLOBAL_NETWORK)
      fi
      #Run container
      run=$(docker run -p "$NODE_RUN_PORTS_1" -v "$(pwd)$NODE_RUN_VOLUMES_1" -v "$NODE_RUN_VOLUMES_2" --network $GLOBAL_NETWORK -d --name $NODE_RUN_NAME $NODE_IMAGE_NAME:$NODE_IMAGE_TAG)
      #Checks if container are running
      if [ $(docker ps | grep -w $NODE_RUN_NAME | wc -l) == '1' ];then
        echo "### Message ### -> Container $NODE_RUN_NAME was created!"
      else
        echo "### Message ### -> An error occurred creating container $NODE_RUN_NAME"
      fi
      ;;
    "postgres")
      #Build if not image exists
      if [ $(docker image list | grep -w $POSTGRES_IMAGE_NAME | grep -w $POSTGRES_IMAGE_TAG | wc -l) == '0' ]; then
        build postgres
      fi
      #Run dependencies
      if [[ $POSTGRES_RUN_DEPENDENCIES != "" ]]; then
        run $POSTGRES_RUN_DEPENDENCIES
      fi
      #Delete container if exists
      if [ $(docker ps -a | grep -w $POSTGRES_RUN_NAME | wc -l) == '1' ];then
        delete=$(docker rm -f $POSTGRES_RUN_NAME)
        echo "### Message ### -> Container $POSTGRES_RUN_NAME deleted!"
      fi
      if [ $(docker volume list | grep -w mydb | wc -l) == '0' ]; then
        createVolume=$(docker volume create mydb)
      fi
      if [ $(docker network list | grep -w $GLOBAL_NETWORK | wc -l) == '0' ]; then
        createNetwork=$(docker network create $GLOBAL_NETWORK)
      fi
      #Run container
      run=$(docker run -p $POSTGRES_RUN_PORTS -v "$POSTGRES_RUN_VOLUMES" $postgres_run_environments --network $GLOBAL_NETWORK  -d --name $POSTGRES_RUN_NAME $POSTGRES_IMAGE_NAME:$POSTGRES_IMAGE_TAG) 
      #Checks if container are running
      if [ $(docker ps | grep -w $POSTGRES_RUN_NAME | wc -l) == '1' ];then
        echo "### Message ### -> Container $POSTGRES_RUN_NAME was created!"
      else
        echo "### Message ### -> An error occurred creating container $POSTGRES_RUN_NAME"
      fi
      ;;
  esac
}

function header {
    clear
    echo "*************************************************************************"
    echo "********************************* Helper ********************************"
    echo "*************************************************************************"
}

function chooseApp()
{
    header
    option=$op2
    while [ "$option" == "" ];do
        if [ $1 == "BUILD" ];then
          echo "###\tBuild image\t###\n"
        else
          echo "###\tRun container\t###\n"
        fi
        echo "1 - NodeJS"
        echo "2 - Postgres"
        echo "0 - Exit"

        read -n 2 -p "Choose an option: " option

        if [ "$option" != "0" ] && [ "$option" != "1" ] && [ "$option" != "2" ];then
            option=""
            echo "Invalid Option!"
        fi

        header
        
    done

    if [ $option == "0" ];then
     exit 0
    fi
    if [ $1 == 'BUILD' ];then
      if [ "$option" == "1" ];then
          build nodejs
      elif [ "$option" == "2" ];then
          build postgres
      fi
    else
      if [ "$option" == "1" ];then
          run nodejs
      elif [ "$option" == "2" ];then
          run postgres
      fi
    fi
}

function kubernetes()
{
    header
    option=$op2
    while [ "$option" == "" ];do
        if [ $1 == "BUILD" ];then
          echo "###\tBuild image\t###\n"
        else
          echo "###\tRun container\t###\n"
        fi
        echo "1 - Apply development(Pods)"
        echo "2 - Apply Scale(Replicaset)"
        echo "3 - Apply Service(Load Balance)"
        echo "4 - All"
        echo "5 - Delete deployment and service"
        echo "0 - Exit"

        read -n 2 -p "Choose an option: " option

        if [ "$option" != "0" ] && [ "$option" != "1" ] && [ "$option" != "2" ] && [ "$option" != "3" ] && [ "$option" != "4" ] && [ "$option" != "5" ];then
            option=""
            echo "Invalid Option!"
        fi

        header
        
    done

    if [ $option == "0" ];then
     exit 0
    fi
    if [ $(docker image list | grep -w $NODE_IMAGE_NAME | grep -w $NODE_IMAGE_TAG | wc -l) == '0' ] && [ "$option" != "5" ]; then
      build nodejs
    fi
    if [ "$option" == "1" ];then
        apply=$(kubectl apply -f ./kube/deployment.yaml)
        echo "### Message ### -> Development Updated!"
    elif [ "$option" == "2" ];then
        apply=$(kubectl apply -f ./kube/scale.yaml)
        echo "### Message ### -> Scale Updated!"
    elif [ "$option" == "3" ];then
        apply=$(kubectl apply -f ./kube/service.yaml)
        echo "### Message ### -> Service Updated!"
    elif [ "$option" == "4" ];then
        apply=$(kubectl apply -f ./kube/deployment.yaml)
        apply=$(kubectl apply -f ./kube/scale.yaml)
        apply=$(kubectl apply -f ./kube/service.yaml)
        echo "### Message ### -> All are updated!"
    elif [ "$option" == "5" ];then
        apply=$(kubectl delete deployment nodejs-api)
        apply=$(kubectl delete svc nodejs-api)
        echo "### Message ### -> Deployment and Service deleted!"
    fi
}

function locust()
{
  delete=$(docker rm -f scc_test)
  replace=$(sed -E "s/host.*/host = http:\/\/$LOCUST_APP_HOST:$LOCUST_APP_PORT\/api\//" ./test/sample.conf > ./test/.locust.conf)
  run=$(docker run -p $LOCUST_RUN_PORT -v $(pwd)$LOCUST_RUN_VOLUME --network $GLOBAL_NETWORK --name scc_test -d $LOCUST_IMAGE_NAME:$LOCUST_IMAGE_TAG)
}

function chooseDelete()
{
    header
    option=$op2
    while [ "$option" == "" ];do
        echo "###\tDelete $(echo $1 | tr '[:upper:]' '[:lower:]')\t###\n"
        echo "1 - NodeJS"
        echo "2 - Postgres"
        echo "3 - All"
        echo "0 - Exit"

        read -n 2 -p "Choose an option: " option

        if [ "$option" != "0" ] && [ "$option" != "1" ] && [ "$option" != "2" ] && [ "$option" != "3" ];then
            option=""
            echo "Invalid Option!"
        fi

        header
        
    done

    if [ $option == "0" ];then
     exit 0
    fi
    if [ $1 == 'CONTAINER' ];then
      if [ "$option" == "1" ];then
          delete_container $NODE_RUN_NAME
      elif [ "$option" == "2" ];then
          delete_container $POSTGRES_RUN_NAME
      elif [ "$option" == "3" ];then
          delete_container $NODE_RUN_NAME
          delete_container $POSTGRES_RUN_NAME
      fi
    else
      if [ "$option" == "1" ];then
          delete_container $NODE_RUN_NAME
          delete_image $NODE_IMAGE_NAME $NODE_IMAGE_TAG
      elif [ "$option" == "2" ];then
          delete_container $POSTGRES_RUN_NAME
          delete_image $POSTGRES_IMAGE_NAME $POSTGRES_IMAGE_TAG
      elif [ "$option" == "3" ];then
          delete_container $NODE_RUN_NAME
          delete_container $POSTGRES_RUN_NAME
          delete_image $NODE_IMAGE_NAME $NODE_IMAGE_TAG
          delete_image $POSTGRES_IMAGE_NAME $POSTGRES_IMAGE_TAG
      fi
    fi
}

function registry()
{
  header
  read -p "Version of image(TAG): " tag
  echo "Trying to registry NodeJS image"
  #Login
  echo $(echo $GITHUB_TOKEN | base64 --decode) | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin
  #Check|Delete
  if [ $(docker image list | grep -w $NODE_IMAGE_NAME | grep -w latest | wc -l) == '0' ]; then
    delete=$(docker image rm -f $NODE_IMAGE_NAME:latest 2>&1)
  fi
  #Build
  if [ $(docker image list | grep -w $NODE_IMAGE_NAME | grep -w $tag | wc -l) == '0' ]; then
    build=$(docker build -t $NODE_IMAGE_NAME:$tag $NODE_DOCKERFILE 2>&1)
  fi
  build=$(docker build -t $NODE_IMAGE_NAME:latest $NODE_DOCKERFILE 2>&1)
  #Registry
  registry=$(docker push $NODE_IMAGE_NAME:$tag 2>&1)
  registry=$(docker push $NODE_IMAGE_NAME:latest 2>&1)
  #Delete
  delete_image $NODE_IMAGE_NAME $tag
  delete_image $NODE_IMAGE_NAME "latest"
  echo "### Message ### -> $NODE_IMAGE_NAME:$tag are registered!"
  echo "### Message ### -> $NODE_IMAGE_NAME:latest are registered!"
}

function menu {
    header
    option=$op2
    while [ "$option" == "" ];do
        echo "###\tMenu\t###\n"
        echo "1 - Build image"
        echo "2 - Run container"
        echo "3 - Delete container"
        echo "4 - Delete image"
        echo "5 - Registry Container"
        echo "6 - Kubernetes"
        echo "7 - Locust"
        echo "0 - Exit"

        read -n 2 -p "Choose an option: " option

        if [ "$option" != "0" ] && [ "$option" != "1" ] && [ "$option" != "2" ] && [ "$option" != "3" ] && [ "$option" != "4" ] && [ "$option" != "5" ] && [ "$option" != "6" ] && [ "$option" != "7" ];then
            option=""
            echo "Invalid Option!"
        fi
        header
        
    done

    if [ $option == "0" ];then
     exit 0
    fi
    if [ "$option" == "1" ];then
        chooseApp "BUILD"
    elif [ "$option" == "2" ];then
        chooseApp "RUN"
    elif [ "$option" == "3" ];then
        chooseDelete "CONTAINER"
    elif [ "$option" == "4" ];then
        chooseDelete "IMAGE"
    elif [ "$option" == "5" ];then
        registry 
    elif [ "$option" == "6" ];then
        kubernetes
    elif [ "$option" == "7" ];then
        locust
    fi
}

#Inicialize menu
menu
