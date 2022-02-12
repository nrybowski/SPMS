import subprocess
import tempfile
import tarfile
import shutil
import io
import os
import json

import cbor

def parse_manifest(manifest_path: str) -> dict:
    """ Takes the path toward a manifest and outputs a dict of plugins
    """
    with open(manifest_path, 'r') as fd:
        manifest = json.load(fd)
    return {plugin: [obj_content['obj'] for obj_name, obj_content in content['obj_code_list'].items()] for plugin, content in manifest['plugins'].items()}

def generate_binding(tar_archive: bytes, plugin: str) -> bytes:
    """ Takes a tar.bz2 compressed archive containing a plugin's source 
    code and outputs the plugin binding
    """

    """ Create temporary directory serving as compilation root """
    tmp_dir = tempfile.mkdtemp(dir='/tmp')

    """ Decompress plugin's source code in the temporary directory """
    with io.BytesIO(tar_archive) as tar_stream:
        with tarfile.open(fileobj=tar_stream, mode='r:bz2') as tar:
            tar.extractall(path=tmp_dir)

    """ Compile plugin """
    plugin_dir = os.path.join(tmp_dir, plugin)
    subprocess.run(['make', '-C', plugin_dir])

    """ Generate plugin's binding """
    manifest_path = os.path.join(plugin_dir, 'manifest.json')
    pluglets = list(filter(lambda entry: entry[-2:] == '.o', os.listdir(plugin_dir)))

    binding_name = '%s.binding' % plugin
    binding_path = os.path.join(plugin_dir, binding_name)
    with open(manifest_path, 'rb') as fd:
        binding = {'%s.plugin' % plugin: fd.read()}

    for pluglet in pluglets:
        with open(os.path.join(plugin_dir, pluglet), 'rb') as pluglet_fd:
            binding[pluglet] = pluglet_fd.read()

    """ Cleanup """
    shutil.rmtree(tmp_dir)

    return cbor.dumps(binding)

if __name__ == '__main__':
    plugin = "hello_world"
    tarfile_name = "%s.tar.bz2" % plugin
    with open(tarfile_name, 'rb') as fd:
        binding = generate_binding(fd.read(), plugin)
        print(binding)
