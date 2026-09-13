"""Access checks for callable functions, mirroring firestore.rules."""

from firebase_functions import https_fn

from . import firebase_client as fb


def require_auth(req: https_fn.CallableRequest):
    """Raises unless the caller is signed in. Returns their uid."""
    if req.auth is None:
        raise https_fn.HttpsError(
            https_fn.FunctionsErrorCode.UNAUTHENTICATED, 'Sign in required'
        )
    return req.auth.uid


def require_admin(req: https_fn.CallableRequest):
    """Raises unless the caller is signed in and their meta doc has admin set."""
    uid = require_auth(req)

    if (fb.read(fb.meta(uid)) or {}).get('admin') is not True:
        raise https_fn.HttpsError(
            https_fn.FunctionsErrorCode.PERMISSION_DENIED, 'Admin access required'
        )

    return uid
