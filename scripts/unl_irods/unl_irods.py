from irods.session import iRODSSession
import irods
import os, sys, json

class Session:
    def __init__(self, username, password):
        zone = 'iplant'
        host = 'data.cyverse.org'
        self.session = iRODSSession(host=host, port=1247, user=username, password=password, zone=zone)
        self.put_opts = { irods.keywords.OPR_TYPE_KW: 1 }
        self.get_opts = { irods.keywords.FORCE_FLAG_KW: 1 }

    def list(self, path):
        results = []
        coll = self.session.collections.get(path)
        for col in coll.subcollections:
            folder = {'name': col.name, 'type': 'folder', 'path': col.path}
            results.append(folder)
        for obj in coll.data_objects:
            file = {'name': obj.name, 'type': 'file', 'path': obj.path}
            results.append(file)
        return results

    def getfile(self, path, local):
        filename = os.path.basename(path)
        local = os.path.join(local, filename)
        self.session.data_objects.get(path, local, **self.get_opts)

    def getfolder(self, path, local):
        objs = self.list(path)

        foldername = os.path.basename(path)
        local = os.path.join(local, foldername)
        if os.path.exists(local):
            if os.path.isfile(local):
                raise
        else:
            os.mkdir(local)

        for obj in objs:
            if obj['type'] == 'file':
                self.getfile(obj['path'], local)
            else:
                self.getfolder(obj['path'], local)

    def putfile(self, local, path):
        filename = os.path.basename(local)
        path = os.path.join(path, filename)
        self.session.data_objects.put(local, path, **self.put_opts)

    def putfolder(self, local, path):
        foldername = os.path.basename(local)
        path = os.path.join(path, foldername)
        self.session.collections.create(path)

        for name in os.listdir(local):
            l = os.path.join(local, name)
            if os.path.isfile(l):
                self.putfile(l, path)
            else:
                self.putfolder(l, path)


def main(argv):
    try:
        method = argv[0]
        username = argv[1]
        password = argv[2]
        sess = Session(username, password)

        if method == 'list':
            results = sess.list(argv[3])
            print(json.dumps(results))
            return

        if method == 'getfile':
            sess.getfile(argv[3], argv[4])
        elif method == 'getfolder':
            sess.getfolder(argv[3], argv[4])
        elif method == 'putfile':
            sess.putfile(argv[3], argv[4])
        elif method == 'putfolder':
            sess.putfolder(argv[3], argv[4])
        else:
            raise
        print('true')

    except Exception as e:
        raise e


if __name__ == "__main__":
   main(sys.argv[1:])


