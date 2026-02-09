# UNIX TP2

## 1 Secure Shell SSH 

### 1.1 Exercice : Connection ssh root 

Selon le manuel (man sshd_config), cette directive définit si l'utilisateur root peut se connecter en SSH. Voici les différentes options disponibles :

- `yes` : Autorise la connexion root avec n'importe quelle méthode d'authentification (mot de passe ou clé publique).

- `prohibit-password` : L'authentification par mot de passe est désactivée pour l'utilisateur root.

- `forced-commands-only` : Autorise root via clé publique, mais seulement pour exécuter des commandes spécifiques.

- `no` : N'autorise pas l'authentification root peu importe la méthode.

**Avantages, Inconvénients et Cas d'usage**

1. `yes` 
- Avantages : Simplicité absolue. Pas besoin de gérer des clés ou de passer par un compte intermédiaire.

- Inconvénients : Risque de sécurité majeur. Le compte root est une cible privilégiée. Si un attaquant trouve le mot de passe par "brute force", il a les pleins pouvoirs instantanément.

- Quand l'utiliser : Uniquement dans un environnement de laboratoire isolé ou lors d'une phase de déploiement initial très courte. À bannir en production.

2. `prohibit-password` 
- Avantages : Très sécurisé. Les attaques par force brute sur le mot de passe sont impossibles puisque SSH n'accepte que les clés cryptographiques.

- Inconvénients : Nécessite d'avoir copié sa clé publique sur le serveur au préalable.

- Quand l'utiliser : C'est le réglage par défaut recommandé si on a absolument besoin d'un accès root direct (pour des scripts d'administration automatisés, par exemple).

3. `forced-commands-only`
- Avantages : Sécurité maximale pour des tâches spécifiques. L'accès root est "bridé".

- Inconvénients : Très contraignant pour une utilisation humaine normale.

- Quand l'utiliser : Pour des sauvegardes automatisées ou du monitoring où l'outil distant ne doit faire qu'une seule chose précise.

4. `no` 
- Avantages : La meilleure pratique de sécurité. Oblige à se connecter avec un utilisateur standard, puis à utiliser sudo ou su. Cela crée une trace (log) de qui a tenté de devenir root.

- Inconvénients : Un peu plus long au quotidien (deux étapes pour passer root).

- Quand l'utiliser : Dans la majorité des cas. C'est la norme de sécurité standard pour tous les serveurs exposés à Internet.

### 1.2 Exercice : Authentification par clef / Génération de clefs

Pour générer le couple de clefs (publique et privée) sur ma machine hôte (ma machine locale Linux), j'ai utilisé le terminal Ghosty avec l'utilitaire OpenSSH.

```bash 
ssh-keygen -t rsa -b 4096
```

- `-t rsa` : Spécifie le type d'algorithme (RSA est le standard).

- `-b 4096` : Définit une taille de 4096 bits pour une sécurité accrue.

**La question de la "Passphrase"**
Lors de la génération, j'ai laissé le champ passphrase vide comme demandé pour le TP.

Pourquoi est-ce une mauvaise idée en conditions réelles ? La passphrase agit comme un mot de passe qui chiffre la clef privée sur le disque dur.

Sans passphrase : Si quelqu'un vole l'ordinateur ou accède aux fichiers, il peut utiliser la clef privée instantanément pour se connecter à tous nos serveurs. C'est un "single point of failure".

Avec passphrase : Même si le fichier de la clef est dérobé, l'attaquant ne peut rien en faire sans le code pour la déchiffrer. C'est une couche de sécurité indispensable (Authentification à deux facteurs : ce que je possède [la clef] et ce que je sais [la passphrase]).

### 1.3 Exercice : Authentification par clef / Connexion serveur

Pour cet exercice, j'ai utilisé l'utilitaire `ssh-copy-id`, qui permet d'automatiser proprement le dépôt de la clef publique sur le serveur Debian.

**Procédure simplifiée**

Depuis le terminal de ma machine hôte, j'ai exécuté la commande suivante :
```bash
ssh-copy-id root@IP_SERVEUR
```

L'outil m'a demandé le mot de passe de l'utilisateur root une dernière fois, puis a confirmé que la clef avait été ajoutée.

**Ce que l'outil a fait automatiquement** 

Bien que je n'aie tapé qu'une seule commande, `ssh-copy-id` a effectué les actions requises par l'énoncé sur le serveur distant :

1. **Création du dossier** : Il a vérifié l'existence du dossier `/root/.ssh/` et l'a créé si nécessaire.
2. **Gestion du fichier** : Il a créé (ou complété) le fichier `/root/.ssh/authorized_keys` en y injectant le contenu de ma clef publique `id_rsa.pub`.
3. **Sécurisation des droits (Permissions)** : L'outil est programmé pour respecter les exigences d'OpenSSH. Il a automatiquement appliqué les permissions restrictives :
   * Dossier `.ssh` : Droits `700` (Seul root peut y accéder).
   * Fichier `authorized_keys` : Droits `600` (Seul root peut lire/écrire).

![](./.Image07.png)

### 1.4 Exercice : Authentification par clef : depuis la machine hote

Après l'utilisation de l'outil, j'ai testé la connexion :
```bash
ssh root@IP_SERVEUR
```

**Résultat** : La connexion s'établit instantanément sans demande de mot de passe. L'authentification par clef est maintenant opérationnelle.

![](./.Image08.png)

### 1.5 Exercice : Sécurisation de l'accès SSH

#### La Procédure : Root par clef uniquement

Pour sécuriser l'accès, on modifie le comportement du démon SSH (sshd). La procédure que tu as trouvée est correcte. Voici les étapes précises à reporter :

**Édition du fichier :**
```bash
nano /etc/ssh/sshd_config
```

**Modifications cibles :**
- `PermitRootLogin prohibit-password` : Cette ligne est cruciale. Elle dit : "Root peut se connecter, mais jamais avec un mot de passe (clés uniquement)".
- `PasswordAuthentication no` : Désactive les mots de passe pour tous les utilisateurs.

#### Qu'est-ce qu'une attaque "Brute-Force" ?

Une attaque par force brute (bruteforce attack) consiste à tester, l'une après l'autre, chaque combinaison possible d'un mot de passe ou d'une clé pour un identifiant donné afin se connecter au service ciblé.

#### Autres techniques de protection (Alternative & Compléments)

Lorsqu'un serveur a plusieurs utilisateurs, l'administrateur dispose d'autres outils pour renforcer la sécurité :

**A. Changer le port par défaut** 

Par défaut, SSH écoute sur le port 22.

- **Action** : Modifier `Port 22` en `Port 2222` (par exemple) dans `sshd_config`.
- **Avantages** : Élimine 99% des attaques automatiques qui ne scannent que le port 22.
- **Inconvénients** : Ce n'est pas une sécurité absolue (un scan de ports complet trouvera le nouveau port).

**B. Fail2Ban (Le "Bouncer")**

C'est un logiciel qui surveille les journaux de connexion.

- **Action** : `apt install fail2ban`.
- **Fonctionnement** : Si une IP se trompe de mot de passe 3 fois, Fail2Ban bloque cette IP au niveau du pare-feu (Firewall) pendant 10 minutes ou plus.
- **Avantages** : Très efficace pour décourager les robots sans bloquer les utilisateurs légitimes.

**C. AllowUsers (La "Liste Blanche")**

- **Action** : Ajouter `AllowUsers alice bob` dans la configuration.
- **Avantages** : Seuls les utilisateurs listés peuvent tenter de se connecter. Même si un attaquant trouve le mot de passe du compte test, il sera rejeté car il n'est pas dans la liste.

**D. L'authentification à deux facteurs (2FA/MFA)**

- **Action** : Utiliser un module comme `libpam-google-authenticator`.
- **Avantages** : Même avec la clé SSH (ou le mot de passe) volée, l'attaquant a besoin du code temporaire sur ton téléphone. C'est le niveau de sécurité bancaire.

## 2. Processus

### 2.1 Etude des processus UNIX 

1. Commande ps pour afficher la liste de tous les processus tournant sur ma machine 
```bash 
ps -eo pid,pcpu,user,comm,%mem,lstart,cputime,stat
```

L'information TIME correspond au temps CPU cumulé, format "[DD-]HH:MM:SS".

Le processus ayant utilisé le plus le processeur dur ma machine : 
```bash 
%CPU USER     COMMAND         %MEM     TIME                  STARTED STAT
0.4 root     kworker/0:3-eve  0.0 00:00:04 Mon Feb  2 09:44:44 2026 I
```

Le premier processus démarré lancé après le démarrage du système : 
```bash 
ps -eo pcpu,user,comm,%mem,lstart,cputime,stat --sort=lstart
%CPU USER     COMMAND         %MEM                  STARTED     TIME STAT
 0.0 root     systemd          0.7 Mon Feb  2 09:44:43 2026 00:00:00 Ss
```

Le processus avec l'ID 1 est lancé au démarrage du système. Son heure de lancement correspond donc à l'heure de boot.
```bash 
ps -p 1 -o lstart=
Mon Feb  2 09:44:43 2026
```

Temps depuis lequel le serveur tourne :
```bash 
uptime -p
up 35 minutes
```
Nombre de processus en cours sur ma machine :
```bash
grep 'processes' /proc/stat
processes 1329
```

2. Commande affichant le processus parent :
```bash 
ps -o ppid
```

Pour trouver les processus parent de `ps` on peut rajouter l'argument `-H` (hiérarchie), qui affiche les processus avec une indentation, pour signifier la parenté :
```bash 
ps -eo pid,ppid,comm -H 
PID    PPID COMMAND
1       0 systemd
687       1   sshd
1945     687     sshd-session
   1952    1945       sshd-session
   1953    1952         bash
   2126    1953           ps
```

3. Pour récupérer les parents de bash on peut aussi utiliser la commande `pstree` : 
```bash 
apt update
apt search pstree 
apt install psmisc
```

Après l'installation on tape la commande suivante :
```bash 
pstree -s $$
systemd───sshd───sshd-session───sshd-session───bash───pstree
```

- `$$` est une variable shell qui contient le PID de notre terminal actuel.

- `-s` (show parents) affiche les ancêtres du processus spécifié.

4. La commande `top`

Pour afficher les processus trier par occupation de mémoire dans l'ordre décroissant, il suffit d'appuyer sur la touche `M` une fois dans l'outil `top`.

<img width="868" height="1112" alt="image" src="https://github.com/user-attachments/assets/fee8318d-c5cc-44d2-bbd8-93eb7b3ed9fb" />

Le processus le plus gourmand sur ma machine est `systemd`, qui est un gestionnaire de systèmes et de services pour les systèmes d'exploitation Linux.

**Voici les touches magiques pour personnaliser notre vue :**

`z` : Active/désactive l'affichage en couleurs.

`b` : Met en gras ou en surbrillance la colonne de tri (très utile pour voir ce que l'on fait).

`<` et `>` : Permettent de déplacer la colonne de tri vers la gauche ou la droite. C'est la méthode la plus simple pour changer la colonne de tri (passer de %CPU à %MEM ou PID).

`f` : Accède au menu de gestion des champs (Field Management) pour ajouter/supprimer des colonnes ou choisir le tri de façon précise.

- `htop` est une version moderne et beaucoup plus conviviale de top.

<img width="1564" height="1113" alt="image" src="https://github.com/user-attachments/assets/078deb71-6651-4c18-af56-3ab46a731d05" />

**Avantages de htop**

- Visuel : Utilise des barres de couleur pour le CPU (par cœur), la RAM et le Swap. C'est instantanément lisible.

- Navigation : On peut faire défiler la liste verticalement et horizontalement avec les flèches du clavier.

- Interaction : On peut tuer un processus (F9) ou changer sa priorité (F7/F8) sans avoir à taper son PID manuellement.

- Recherche : Supporte la recherche (/) et le filtrage (F4) de processus de manière intuitive.

**Inconvénients de htop**

- Installation : Il n'est pas toujours installé par défaut sur les systèmes minimaux, alors que top est présent partout.

- Ressources : Il consomme légèrement plus de ressources que top, ce qui peut compter sur des systèmes très anciens ou très chargés.

## 3 Arrêt d'un processus

On souhaitye arrêter un processus avec les commandes `jobs` et `fg`. 

<img width="392" height="332" alt="image" src="https://github.com/user-attachments/assets/c82418f2-ddd4-481d-8f94-ed63a4f1edbd" />

```bash
jobs
[1]-  Stopped                 ./date.sh
[2]+  Stopped                 ./date-toto.sh
```

<img width="200" height="202" alt="image" src="https://github.com/user-attachments/assets/a1eba131-86dc-4620-b4a3-f3e09a28735c" />

<img width="199" height="273" alt="image" src="https://github.com/user-attachments/assets/25ff3925-7bcd-4ff3-95a0-f07a8758586f" />

On souhaite faire la même chose mais cette fois avec `ps` et `kill`.
```bash
ps
    PID TTY          TIME CMD
   1953 pts/0    00:00:00 bash
  15909 pts/0    00:00:00 date.sh
  15918 pts/0    00:00:00 sleep
  15919 pts/0    00:00:00 date-toto.sh
```

Cependant dans notre script, la commande sleep 1 est un processus fils. Quand le shell exécute sleep, il se met en pause et attend que le fils se termine avant de passer à la commande suivante (echo).
Lorsqu'on envoies un kill au script parent (date.sh), celui-ci reçoit le signal, mais il est "occupé" à attendre la fin du sleep.
Par défaut, le shell ne traite les signaux en attente qu'une fois que la commande en cours (le fils) est terminée.

Dès que le sleep 1 s'arrête, le shell reçoit enfin le signal, mais il a une fraction de seconde pour l'interpréter avant de lancer l'instruction suivante (echo, puis date, puis un nouveau sleep). Si le signal arrive pile au moment où un nouveau sleep démarre, tu repars pour un tour d'attente.

Contrairement au kill standard (SIGTERM) qui demande au processus de s'arrêter lui-même, le SIGKILL (9) ne s'adresse pas au script. Il s'adresse au Noyau (Kernel).

Le Kernel voit le signal -9 et supprime immédiatement le processus de la table des processus, sans demander l'avis du script et sans attendre la fin du sleep en cours.
```bash
ps
    PID TTY          TIME CMD
   1953 pts/0    00:00:00 bash
  15909 pts/0    00:00:00 date.sh
  15918 pts/0    00:00:00 sleep
  15919 pts/0    00:00:00 date-toto.sh
  15928 pts/0    00:00:00 sleep
  15942 pts/0    00:00:00 ps
root@debiansf:~# kill -9 15909
[1]-  Killed                  ./date.sh
root@debiansf:~# ps
    PID TTY          TIME CMD
   1953 pts/0    00:00:00 bash
  15919 pts/0    00:00:00 date-toto.sh
  15928 pts/0    00:00:00 sleep
  15957 pts/0    00:00:00 ps
  root@debiansf:~# kill -9 15919
root@debiansf:~# ps
    PID TTY          TIME CMD
   1953 pts/0    00:00:00 bash
  15959 pts/0    00:00:00 ps
[2]+  Killed                  ./date-toto.sh
```

## 4 Les tubes

`cat` : concaténe des fichiers et les affiche sur la sortie standard

`tee` : lit l’entrée standard et l’écrit à la fois dans le résultat standard et dans un ou plusieurs fichiers. Dans une redirection de résultat normale, toutes les lignes de la commande seront écrites dans un fichier, mais on ne peut pas voir le résultat en même temps. En utilisant la commande **Tee**, nous pouvons y parvenir.

### Analyse de commandes

`ls | cat` : Cette commande permet de transmettre à `cat` la liste des fichiers envoyés par `ls`, qui l'affiche simplement dans le terminal.

```bash
ls | cat
date.sh
date-toto.sh
liste
man
```

`ls -l | cat > liste` : Le flux de `ls -l` passe par `cat`, puis est **redirigé** par l'opérateur `>` vers le fichier nommé `liste`.

```bas 
root@debiansf:~# ls -l | cat > liste
root@debiansf:~# ls
date.sh  date-toto.sh  liste  man
root@debiansf:~# cat liste
total 8
-rwxr-xr-x 1 root root 65 Feb  2 12:13 date.sh
-rwxr-xr-x 1 root root 86 Feb  2 12:02 date-toto.sh
-rw-r--r-- 1 root root  0 Feb  7 15:43 liste
-rw-r--r-- 1 root root  0 Feb  7 15:36 man
```

`ls -l | tee liste` : prend le résultat de `ls -l`, l'écrit dans le fichier `liste` **ET** l'affiche en même temps sur votre terminal.

```bash
ls -l | tee liste
total 8
-rwxr-xr-x 1 root root 65 Feb  2 12:13 date.sh
-rwxr-xr-x 1 root root 86 Feb  2 12:02 date-toto.sh
-rw-r--r-- 1 root root  0 Feb  7 15:46 liste
-rw-r--r-- 1 root root  0 Feb  7 15:36 man
```

`ls -l | tee liste | wc -l` : 

1. `ls -l` génère la liste.
2. `tee` enregistre cette liste dans le fichier `liste`.
3. `tee` envoie également cette liste vers la commande suivante : `wc -l`.

Le fichier `liste` est créé/mis à jour avec le détail des fichiers, et votre terminal affiche uniquement **le nombre de lignes** (grâce à `wc -l`).

```bash
ls -l | tee liste | wc -l
5
```

## 5 Journal système rsyslog

Le service rsyslog n'est pas actif sur ma machine, je vais donc l'installer. 

```bas
apt update 
apt install rsyslog
```

Après installation, le service est actif, et le PID du démon et `1809`.

```bas
ps -eo pid,ppid,comm
    PID    PPID COMMAND
   1809       1 rsyslogd
```

### ryslog.conf

```bash
cat /etc/rsyslog.conf
###############
#### RULES ####
###############

#
# Log anything besides private authentication messages to a single log file
#
*.*;auth,authpriv.none          -/var/log/syslog

#
# Log commonly used facilities to their own log file
#
auth,authpriv.*                 /var/log/auth.log
cron.*                          -/var/log/cron.log
kern.*                          -/var/log/kern.log
mail.*                          -/var/log/mail.log
user.*                          -/var/log/user.log

#
# Emergencies are sent to everybody logged in.
#
*.emerg                         :omusrmsg:*
```

`/var/log/syslog` : Presque tout ce qui se passe sur le serveur finit ici, sauf ce qui est sensible (mots de passe, connexions SSH).

```bas
cat /var/log/syslog
2026-02-07T15:54:25.934795+01:00 debiansf systemd[1]: Listening on syslog.socket - Syslog Socket.
2026-02-07T15:54:25.935296+01:00 debiansf systemd[1]: Starting rsyslog.service - System Logging Service...
2026-02-07T15:54:25.934348+01:00 debiansf systemd[1]: Started rsyslog.service - System Logging Service.
2026-02-07T15:54:25.935215+01:00 debiansf rsyslogd: imuxsock: Acquired UNIX socket '/run/systemd/journal/syslog' (fd 3) from systemd.  [v8.2504.0]
2026-02-07T15:54:25.935329+01:00 debiansf rsyslogd: [origin software="rsyslogd" swVersion="8.2504.0" x-pid="1809" x-info="https://www.rsyslog.com"] start
2026-02-07T15:54:25.934970+01:00 debiansf kernel: Linux version 6.12.63+deb13-amd64 (debian-kernel@lists.debian.org) (x86_64-linux-gnu-gcc-14 (Debian 14.2.0-19) 14.2.0, GNU ld (GNU Binutils for Debian) 2.44) #1 SMP PREEMPT_DYNAMIC Debian 6.12.63-1 (2025-12-30)
```

`/var/log/auth.log` : C'est ici qu'on trouveras les tentatives de connexion, l'utilisation de `sudo`, et les erreurs de login. C'est le fichier le plus important pour la surveillance de la sécurité.

```bash
cat /var/log/auth.log
2026-02-07T16:16:11.905711+01:00 debiansf sshd-session[2445]: Accepted publickey for root from 192.168.1.37 port 60234 ssh2: RSA SHA256:WvpNbYpgw29Xs9duM4Ej+IUSkNN36mC3SLAHdwHlT1I
2026-02-07T16:16:11.911979+01:00 debiansf sshd-session[2445]: pam_unix(sshd:session): session opened for user root(uid=0) by root(uid=0)
2026-02-07T16:16:11.913293+01:00 debiansf systemd-logind[604]: New session 4 of user root.
2026-02-07T16:17:01.452790+01:00 debiansf CRON[2460]: pam_unix(cron:session): session opened for user root(uid=0) by root(uid=0)
2026-02-07T16:17:01.457139+01:00 debiansf CRON[2460]: pam_unix(cron:session): session closed for user root
2026-02-07T16:21:18.447004+01:00 debiansf sshd-session[2452]: Received disconnect from 192.168.1.37 port 60234:11: disconnected by user
2026-02-07T16:21:18.452054+01:00 debiansf sshd-session[2452]: Disconnected from user root 192.168.1.37 port 60234
2026-02-07T16:21:18.452421+01:00 debiansf sshd-session[2445]: pam_unix(sshd:session): session closed for user root
2026-02-07T16:21:18.452747+01:00 debiansf sshd-session[2445]: syslogin_perform_logout: logout() returned an error
2026-02-07T16:21:18.464461+01:00 debiansf systemd-logind[604]: Session 4 logged out. Waiting for processes to exit.
2026-02-07T16:21:18.467942+01:00 debiansf systemd-logind[604]: Removed session 4.
```

`/var/log/cron.log` : Toutes les activités du planificateur de tâches.

```bas
cat /var/log/cron.log
2026-02-07T16:17:01.454776+01:00 debiansf CRON[2462]: (root) CMD (cd / && run-parts --report /etc/cron.hourly)
2026-02-07T16:18:46.165619+01:00 debiansf cron[2530]: (CRON) INFO (pidfile fd = 3)
2026-02-07T16:18:46.167871+01:00 debiansf cron[2530]: (CRON) INFO (Skipping @reboot jobs -- not system startup)
```

`/var/log/kern.log` : Les messages directs du noyau (ceux que tu vois aussi avec `dmesg`).

```bas
cat /var/log/kern.log
2026-02-07T15:54:25.934970+01:00 debiansf kernel: Linux version 6.12.63+deb13-amd64 (debian-kernel@lists.debian.org) (x86_64-linux-gnu-gcc-14 (Debian 14.2.0-19) 14.2.0, GNU ld (GNU Binutils for Debian) 2.44) #1 SMP PREEMPT_DYNAMIC Debian 6.12.63-1 (2025-12-30)
2026-02-07T15:54:25.935523+01:00 debiansf kernel: Command line: BOOT_IMAGE=/boot/vmlinuz-6.12.63+deb13-amd64 root=UUID=45830342-4dd1-47c5-9613-5c2efaf0a64e ro quiet
2026-02-07T15:54:25.935526+01:00 debiansf kernel: BIOS-provided physical RAM map:
2026-02-07T15:54:25.935527+01:00 debiansf kernel: BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
```

### À quoi sert cron ?

Le service **cron** est un démon (service en arrière-plan) qui permet :

- **Planifier l'exécution automatique de tâches** à des moments précis
- Exécuter des scripts ou commandes de manière répétitive (quotidienne, hebdomadaire, mensuelle, etc.)
- Gérer les tâches système de maintenance automatique
- Exécuter des tâches utilisateur programmées

### La commande tail -f

La commande `tail -f` permet de :

- **Suivre un fichier en temps réel** ("follow")
- Afficher les nouvelles lignes ajoutées au fichier au fur et à mesure
- Rester active et continuer à afficher les ajouts jusqu'à interruption (Ctrl+C)

```bash
tail -f /var/log/syslog
2026-02-07T16:16:11.928603+01:00 debiansf systemd[1]: Started session-4.scope - Session 4 of User root.
2026-02-07T16:17:01.454776+01:00 debiansf CRON[2462]: (root) CMD (cd / && run-parts --report /etc/cron.hourly)
2026-02-07T16:18:43.022177+01:00 debiansf dhcpcd[637]: enp0s3: requesting DHCPv6 information
2026-02-07T16:18:46.133378+01:00 debiansf systemd[1]: Stopping cron.service - Regular background program processing daemon...
2026-02-07T16:18:46.135048+01:00 debiansf systemd[1]: cron.service: Deactivated successfully.
2026-02-07T16:18:46.136310+01:00 debiansf systemd[1]: Stopped cron.service - Regular background program processing daemon.
2026-02-07T16:18:46.151043+01:00 debiansf systemd[1]: Started cron.service - Regular background program processing daemon.
2026-02-07T16:18:46.165619+01:00 debiansf cron[2530]: (CRON) INFO (pidfile fd = 3)
2026-02-07T16:18:46.167871+01:00 debiansf cron[2530]: (CRON) INFO (Skipping @reboot jobs -- not system startup)
2026-02-07T16:21:18.462523+01:00 debiansf systemd[1]: session-4.scope: Deactivated successfully.
```

(Note : Sur les versions récentes de Debian, `/var/log/messages` est souvent remplacé par `/var/log/syslog`. Si le fichier `messages` n'existe pas, utilisez `syslog`)

Pendant que notre commande `tail -f` tourne dans le premier terminal :

1. On ouvre un **deuxième terminal**.
2. On relance le service cron avec la commande suivante :

```bash
systemctl restart cron
```

On remarque alors que dès qu'on valide la commande dans l'autre shell, de nouvelles lignes vont apparaître instantanément dans votre fenêtre de log.

```bash
2026-02-07T16:26:29.454770+01:00 debiansf systemd[1]: Started session-6.scope - Session 6 of User root.
2026-02-07T16:26:35.595715+01:00 debiansf systemd[1]: Stopping cron.service - Regular background program processing daemon...
2026-02-07T16:26:35.596732+01:00 debiansf systemd[1]: cron.service: Deactivated successfully.
2026-02-07T16:26:35.597625+01:00 debiansf systemd[1]: Stopped cron.service - Regular background program processing daemon.
2026-02-07T16:26:35.608756+01:00 debiansf systemd[1]: Started cron.service - Regular background program processing daemon.
2026-02-07T16:26:35.626830+01:00 debiansf cron[2743]: (CRON) INFO (pidfile fd = 3)
2026-02-07T16:26:35.628428+01:00 debiansf cron[2743]: (CRON) INFO (Skipping @reboot jobs -- not system startup)
```

### À quoi sert logrotate ?

Le fichier `/etc/logrotate.conf` configure le système **logrotate** qui permet de :

1. **Rotation des fichiers de logs**
   - Renomme les anciens fichiers de logs (ex: syslog → syslog.1)
   - Crée de nouveaux fichiers vides pour continuer la journalisation
2. **Compression des logs archivés**
   - Compresse les anciens logs pour économiser l'espace disque
   - Format généralement utilisé : gzip (.gz)
3. **Suppression des vieux logs**
   - Supprime automatiquement les logs trop anciens
4. **Gestion de l'espace disque**
   - Maintient un nombre limité de fichiers de logs
   - Définit des politiques de rétention

### dmesg

**Modéle de processeur**

```bas
dmesg | grep -i "CPU0"
[    0.197212] smpboot: CPU0: 13th Gen Intel(R) Core(TM) i7-13650HX (family: 0x6, model: 0xb7, stepping: 0x1)
```

**Cartes réseaux**

```bash
dmesg | grep -iE "eth|network|ethernet|wlan"
[    0.832312] e1000: Intel(R) PRO/1000 Network Driver
[    1.377956] e1000 0000:00:03.0 eth0: (PCI:33MHz:32-bit) 08:00:27:95:de:52
[    1.377965] e1000 0000:00:03.0 eth0: Intel(R) PRO/1000 Network Connection
[    1.379422] e1000 0000:00:03.0 enp0s3: renamed from eth0
```

