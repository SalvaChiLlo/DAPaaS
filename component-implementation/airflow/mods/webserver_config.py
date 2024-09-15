from __future__ import annotations
import os
import logging
from flask_appbuilder.const import AUTH_REMOTE_USER

from flask_appbuilder.security.views import AuthRemoteUserView
from flask_appbuilder import expose
from flask import redirect, request, g
from urllib.parse import unquote
import json
from flask import flash, redirect
from airflow.www.security import AirflowSecurityManager
from flask_appbuilder.utils.base import get_safe_redirect
from flask_appbuilder._compat import as_unicode
from flask_login import login_user, logout_user
import jwt
from jwt import PyJWKClient

log = logging.getLogger(__name__)
# Flask-WTF flag for CSRF
WTF_CSRF_ENABLED = True
# ----------------------------------------------------
# AUTHENTICATION CONFIG
# ----------------------------------------------------
# For details on how to set up each of the following authentication, see
# http://flask-appbuilder.readthedocs.io/en/latest/security.html# authentication-methods
# for details.

# Uncomment to setup Full admin role name
# AUTH_ROLE_ADMIN = 'Admin'
# Uncomment and set to desired role to enable access without authentication
AUTH_ROLE_PUBLIC = None
# Will allow user self registration
AUTH_USER_REGISTRATION = True
AUTH_USER_REGISTRATION_ROLE = "Admin"
AUTH_ROLES_SYNC_AT_LOGIN = True
AUTH_ROLES_MAPPING = {
    "airflow_admin": ["Admin"],
    "airflow_op": ["Op"],
    "airflow_user": ["User"],
    "airflow_viewer": ["Viewer"],
    "airflow_public": ["Public"],
}

WEBSERVER_BASE_URL = os.getenv("AIRFLOW__WEBSERVER__BASE_URL")
SESSION_COOKIE_NAME = "airflow_session"

class CustomRemoteUserView(AuthRemoteUserView):
    login_template = ""

    @expose("/login/")
    def login(self):
      auth_header = request.headers.get('Authorization', None)
      if auth_header is None or not auth_header.startswith("Bearer "):
          return redirect(f"{WEBSERVER_BASE_URL.replace('/airflow', '/login')}")

      token = auth_header.split(" ")[1]

      try:
          # Directly decode the JWT token without validation
          payload = jwt.decode(token, options={"verify_signature": False})
      except jwt.DecodeError:
          flash("Failed to decode token", "warning")
          return redirect(f"{WEBSERVER_BASE_URL.replace('/airflow', '/login')}")

      email = payload.get("email")
      username = payload.get("name")
      if username and email:
          user = self.appbuilder.sm.auth_user_remote_user({
              "user": email, 
              "first_name": username.split(" ")[0], 
              "last_name": " ".join(username.split(" ")[1:]), 
              "email": email
          })
          if user is None:
              flash(as_unicode(self.invalid_login_message), "warning")
          else:
              login_user(user)
      else:
          return redirect(f"{WEBSERVER_BASE_URL.replace('/airflow', '/login')}")

      next_url = request.args.get("next", "")
      return redirect(get_safe_redirect(next_url))

    @expose("/logout/")
    def logout(self):
        logout_user()

        # Clear the session cookie
        response = redirect(f"{WEBSERVER_BASE_URL.replace('/airflow', '/auth/sign_out')}")
        response.delete_cookie("session") # Airflow session
        return response


class RemoteUserSecurityManager(AirflowSecurityManager):
    authremoteuserview = CustomRemoteUserView

    def auth_user_remote_user(self, userinfo):
        user = self.find_user(email=userinfo["email"], username=userinfo["user"])

        # User does not exist, create one if auto user registration.
        if user is None and self.auth_user_registration:
            user = self.add_user(
                username=userinfo["user"],
                first_name=userinfo["first_name"],
                last_name=userinfo["last_name"],
                email=userinfo["email"],
                role=self.find_role(self.auth_user_registration_role),
            )

        # If user does not exist on the DB and not auto user registration,
        # or user is inactive, go away.
        elif user is None or (not user.is_active):
            username = userinfo["user"]
            log.info(f"Login Failed for user: ${username}")
            return None

        self.update_user(user)
        self.update_user_auth_stat(user)
        return user

AUTH_TYPE = AUTH_REMOTE_USER
SECURITY_MANAGER_CLASS = RemoteUserSecurityManager
