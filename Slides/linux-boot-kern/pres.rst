.. note::
    Présentation sur les fondamentaux d'un système GNU/Linux. Présentation des
    contraintes et fonctionnement du boot et du kernel.

.. style::
    :transition.name: none
    :list.expose: fade
    :layout.valign: center
    :Default.margin_left: 100
    :literal_block.margin_left: 100
    :line_block.margin_left: 100

.. layout::
    :image: inge_logo.jpg;halign=left;valign=bottom

-----------------------------------

.. page-style::
    :align: center

**Architecture de systèmes GNU/Linux**

Architecture de systèmes GNU/Linux
----------------------------------
Pourquoi GNU/Linux ?

*   Linux est un abus de langage
*   Système d'exploitation

    *   GNU = Tous les outils constituant l'OS
    *   Linux = Noyau

Le boot
-------


GRUB : Séquence du boot
-----------------------
1.  Le bios charge l'enregistrement MBR (Stage 1)
#.  Stage 1 charge les données du début du disque (1.5)
#.  Stage 1.5 contient les informations propres au FS et charge Stage 2
#.  Stage 2 est conscient du filesystem et charge les divers fichiers
    nécessaires au boot :

    *   Kernel
    *   (Initial Ramdisk)

GRUB : Installation
-------------------
.. code:: raw

    grub-install /dev/sda

Ou :

.. code:: raw
    grub
    grub> root (hd0,0)
    grub> setup (hd0)
    grub> quit

GRUB : Fichier de configuration
-------------------------------
.. code:: grub

    default 0
    timeout 10
    title Linux
    root (hd0,0)
    kernel /boot/vmlinuz
    initrd /boot/initramfs

Le système de fichiers
----------------------
.. note::
    Reiserfs :  premier fs journalisé à être intégré à Linux
                supporte l'indexage des dossiers
                allocation d'inode dynamique
    ext :       FS de standard de Linux
    zfs :       "Penser gros SAN", l'ipv6 du storage capacité maximale monstrueuse.

Linux peut manipuler un grand nombre de systèmes de fichiers, dont :

*   reiserfs
*   ext2/ext3/ext4
*   btrfs
*   zfs

ext
---
*   Extented Filesystem
*   *Historique*, premier FS dédié à Linux
*   Remplaçant de Minix fs
*   Taille de partition max 2GB vs 64MB
*   Nom de fichier max de 255 vs 14

ext2
----
.. note::
    Système de fichier longtemps adopté par la majorité des distributions.
    Développé à la base par un Français

*   Amélioration de ext
*   Nom de fichiers plus grand
*   Taille des fichiers plus grande.
*   Pensé pour durer (structures avec emplacements pour upgrades)
*   Découpage des fichiers en blocs indexés dans des inodes

ext3
----
*   Upgrade d'ext2
*   Ajout de la journalisation
*   Indexing des répertoires
*   Possibilité d'upgrade depuis ext2

ext3
----
Modification du type de fichier :

.. code:: bash

    # Ajout de la journalisation
    tune2fs -j partition

    # Suppression de la journalisation
    tune2fs -O ^has_journal partition
    fsck partition

ext4
----
*   Ajout du support pour les gros stockages
*   Allocation d'inode dynamique
*   Checksum du journal
*   Extent (Allocation d'un gros bloc de donnée contigu)

Ext2/3 : Structure d'un inode
-----------------------------
*   C'est un enregistrement (fichier, dossier, etc)
*   Sert à attribuer des blocs à un fichier
*   Contient des metadatas sur le fichier :

    *   Owner
    *   Permissions
    *   Timestamps (date d'accès, modification, etc)
    *   ...

*   Les champs jusqu'à 12 servent à adresser directement un bloc

Ext2/3 : Inode et indirection
-----------------------------
*   Permet d'adresser un grand nombre de blocs
*   Trois niveaux d'indirection :

    Indirection simple
        **(Champ 11)** Le pointeur pointe vers un **direct block** sauf qu'il
        contient des adressse d'autres blocs de données (**indirect block**).
    Double indirection
        **(Champ 12)** Le pointeur pointe vers un **direct block** qui comme pour
        une simple indirection pointe vers des **indirect blocks** eux aussi
        pointant vers des blocs de données, les **double indirect blocks**
    Triple indirection
        **(Champ 13)** Ajout d'un autre niveau d'indirection pour encore plus
        d'adresses.

.. note::
    Implique un très grand nombre de blocs adressables :
    Si l'adresse est stockée sur 32 bits => 4 bytes donc
    nombre de blocs = taille_bloc/taille_adresse) +
    taille_bloc/taille_adresse)^2 + taille_bloc/taille_adresse)^3 + 10
