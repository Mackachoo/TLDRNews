"""Access checks for callable functions, mirroring firestore.rules."""

from firebase_admin import firestore
from firebase_functions import https_fn


def require_admin(req: https_fn.CallableRequest):
    """Raises unless the caller is signed in and their meta doc has admin set."""
    if req.auth is None:
        raise https_fn.HttpsError(
            https_fn.FunctionsErrorCode.UNAUTHENTICATED, 'Sign in required'
        )

    snapshot = firestore.client().collection('meta').document(req.auth.uid).get()
    if not snapshot.exists or (snapshot.to_dict() or {}).get('admin') is not True:
        raise https_fn.HttpsError(
            https_fn.FunctionsErrorCode.PERMISSION_DENIED, 'Admin access required'
        )

    return req.auth.uid
