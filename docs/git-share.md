# GIT

## Qué es GIT?
git es un software de control de versiones.

          A*----*----*---
 MASTER /                \ <<<<<< BRANCH_NAME
        \                / 
          B+---+---+-----

## Glosario
- Repositorio: folder en la nube que contiene nuestro proyecto
- Branch: copia de nuestro repositorio, comunmente usada para realizar cambios sin afectar al branch principal.
- Remote: el lugar donde se encuentra nuestro branch en la nube.
- local: nuestros archivos en la computadora local.

## Comandos básicos

### init
commando usado para inicializar un proyecto con git. normalmente es requerido cuando estamos creando un pryect desde zero
y los comandos que siguen a este deberian ser para configurar el repositorio y branch.

Este comando creara folder .git en nuestro proyecto.

### status
comando usado para ver que archivos hemos cambiado en nuestro branch actual.

### diff
este comando nos muestra en vim una lista de cambios hechos en los archivos indicando con un + las lineas nuevas y con un - las lineas que fueron eliminadas.

### add 
agrega el o los archivos indicados, actualizando el index de estos dejandolos listos para ser enviados en un commit.

### checkout
Este comando tiene varias funciones, la primera es cambiarnos de branch por ejemplo si estamos en una branch A y nos queremos cambiar a una branch B solo ejecutamos:

`$ git checkout <branch>`

Este comando tambien puede ser usado para crear un nuevo branch si le damos la opcion -b 

`$ git checkout -b <new-branch>`

También podemos usarlo para regresar un archivo a su estado anterior si en lugar de una branch le pasamos el nombre de un archivo
`$ git checkout /path/file.ext`

### fetch 
este comando actualiza los indices con la informacion leída desde remote, es decir que si hay alguna branch nueva y nosotros aun no la vemos necesitamos hacer fetch para traer la informacion que esta ahora en el servidor.

### pull
Este comando actualizara los indices locales con los indices de remote actualizando tambien los archivos con los cambios de la otra persona.

### commit 
Marca los cambios registrados como listos para enviar con el comando push, nos permite agregarle un mensaje a nuestros cambios si agregamos la opcion -m seguida del mensaje entre comillas. por ejemplo:

`$ git commit -m "mensaje"`

También nos permite agregar archivos como el methodo add si agregamos la opcion -a por ejemplo:

`$ git commit -a -m "mensaje"`

### push
este comando envia la actualizacion de los indices a nuestro servidor de git. actualizando asi el repositorio con los cambios que hicimos sobre nuestra branch.

### rebase
este comando nos permite bajar los cambios que los demas hayan hecho sobre el mismo branch. Este comando es muy usado para resolver conflictos en los branches.

con la opcion -i <interactive> tambien podemos re escribir los mensajes de los commit, hacer squash de varios commits para juntar todos en un solo commit. Algunas empresas suelen hacer esto para reducir la cantidad de mensajes que hay en un branch.

### merge 
nos permite juntar dos branches en una sola sin necesidad de hacer un PR, es un comando usado tambien para resolver conflictos entre las branches.

### log
Nos muestra el historial de una branch o un archivo. 
con la opcion -p es muy parecido al commando diff muestra los cambios que hubo en el ultimo commit a esa branch.
con la opcion --graph nos agrega una forma mas para visualizar los cambios.


### stash
guarda de manera temporal y en una estructura parecida a una pila, los cambios que tenemos, ya sea para moverlos a otro branch o simplemente para que git nos permita cambiarnos a otro branch sin perder nuestro trabajo actual.
para guardar nuestros cambios en la pila
`$ git stash `

para sacar nuestros cambios de la pila, este comando sacara el ultimo elemento que agregamos al stack, si queremos sacar otro elemento que no sea el ultimo podemos indicar tambien el numero de elemento que queremos
`$ git stash pop [--index]` 
Hay un stack por cada proyecto de git.  no es un stack compartido lo que facilita mas el manejo de cambios.

###

