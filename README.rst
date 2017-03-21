=============
Monasca reclass
=============

This is the basic reclass data for Monasca deployment.

How To
==============

.. code-block:: bash

    $ mkdir -p /usr/share/salt-formulas/
    $ cd /usr/share/salt-formulas
    $ git clone https://github.com/asakhnov/reclass-monasca.git
    $ ln -s /usr/share/salt-formulas/reclass-monasca/system /srv/salt/reclass/classes/system/monasca 
    $ ln -s /usr/share/salt-formulas/reclass-monasca/cluster /srv/salt/reclass/classes/cluster/<name>/monasca

