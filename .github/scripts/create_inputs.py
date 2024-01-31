import json
import os
import re
import subprocess

re_image = re_dockerfile = ''
changed_files = json.loads(os.environ['CHANGED_FILES'])
with open('images.json') as fd:
    builds = json.load(fd)

    dockerfiles = list(map(lambda v: v.removesuffix('.dockerfile'), filter(lambda v: re.match('.*dockerfile$', v), changed_files)))
    if len(dockerfiles) > 0:
        re_dockerfile = '|'.join(dockerfiles)

    if 'images.json' in changed_files:
        try:
            data = subprocess.run(['git', 'show', 'HEAD^:images.json'], stdout=subprocess.PIPE).stdout.decode('utf-8')
            images = json.loads(data)
            with open('images.json', 'r') as fd:
                new_images = json.load(fd)
            diff = list(filter(lambda v: v not in images, new_images))
            if len(diff) > 0:
                re_image = '|'.join(map(lambda v: f"{v['image']}:{v['tag']}", diff))
        except json.decoder.JSONDecodeError:
            re_image = '.*'

    with open(os.environ['GITHUB_OUTPUT'], 'a') as output:
        if re_dockerfile == re_image:
            print('do_build=false', file=output)
            print('::notice title=::no image build changes detected')
        else:
            print('do_build=true', file=output)
            print(f're_dockerfile=({re_dockerfile})', file=output)
            print(f're_image=({re_image})', file=output)
