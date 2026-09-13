"""Single point of contact with Firestore.

Collection paths and the Firestore sentinels live here, so nothing else in
`src/` imports `firebase_admin` directly. Ref helpers take an optional client so
callers holding their own (tests, transactions) can pass it through.
"""

from firebase_admin import firestore

DELETE_FIELD = firestore.DELETE_FIELD
FieldFilter = firestore.FieldFilter
Query = firestore.Query
transactional = firestore.transactional


def db():
    return firestore.client()


#* References ----------------------------------------------------------------


def channels(client=None):
    return (client or db()).collection('channels')


def channel(cid, client=None):
    return channels(client).document(cid)


def video_blocks(cid, client=None):
    return channel(cid, client).collection('videos')


def meta(uid, client=None):
    return (client or db()).collection('meta').document(uid)


#* Reads ---------------------------------------------------------------------


def read(ref, transaction=None):
    """The document as a dict, or None when it does not exist."""
    snapshot = ref.get(transaction=transaction)
    return (snapshot.to_dict() or {}) if snapshot.exists else None


def channel_ids(client=None):
    return [doc.id for doc in channels(client).list_documents()]


#* Writes --------------------------------------------------------------------


def merge(ref, fields, transaction=None):
    if transaction is None:
        ref.set(fields, merge=True)
    else:
        transaction.set(ref, fields, merge=True)
