from irods.session import iRODSSession
import irods
import os

class ISession:
    def __init__(self, username, password):
        self.zone = os.environ['UNL_ZONE']
        self.host = os.environ['UNL_HOST']
        self.username = username
        self.password = password
        self.session = iRODSSession(host=self.host, port=1247, user=username, password=password, zone=self.zone)
        self.put_opts = { irods.keywords.OPR_TYPE_KW: 1 }
        self.get_opts = { irods.keywords.FORCE_FLAG_KW: 1 }

    def _make_path(self, path):
        ret = path
        if path == '':
            ret = os.path.join('/', self.zone, 'home', self.username)
        elif not path.startswith('/'):
            ret = os.path.join('/', self.zone, 'home', self.username, path)
        return ret

    def ilist(self, path):
        path = self._make_path(path)
        return self._list(path)

    def _list(self, path):
        results = []
        coll = self.session.collections.get(path)
        for col in coll.subcollections:
            folder = {'name': col.name, 'type': 'folder', 'path': col.path}
            results.append(folder)
        for obj in coll.data_objects:
            file = {'name': obj.name, 'type': 'file', 'path': obj.path}
            results.append(file)
        return results

    def igetfile(self, path, local):
        path = self._make_path(path)
        self._getfile(path, local)

    def _getfile(self, path, local):
        filename = os.path.basename(path)
        local = os.path.join(local, filename)
        self.session.data_objects.get(path, local, **self.get_opts)

    def igetfolder(self, path, local):
        path = self._make_path(path)
        self._getfolder(path, local)

    def _getfolder(self, path, local):
        objs = self._list(path)

        foldername = os.path.basename(path)
        local = os.path.join(local, foldername)
        if os.path.exists(local):
            if os.path.isfile(local):
                raise
        else:
            os.mkdir(local)

        for obj in objs:
            if obj['type'] == 'file':
                self._getfile(obj['path'], local)
            else:
                self._getfolder(obj['path'], local)

    def iputfile(self, local, path):
        path = self._make_path(path)
        self._putfile(local, path)

    def _putfile(self, local, path):
        filename = os.path.basename(local)
        path = os.path.join(path, filename)
        self.session.data_objects.put(local, path, **self.put_opts)

    def iputfolder(self, local, path):
        path = self._make_path(path)
        self._putfolder(local, path)

    def _putfolder(self, local, path):
        foldername = os.path.basename(local)
        path = os.path.join(path, foldername)
        self.session.collections.create(path)

        for name in os.listdir(local):
            l = os.path.join(local, name)
            if os.path.isfile(l):
                self._putfile(l, path)
            else:
                self._putfolder(l, path)





