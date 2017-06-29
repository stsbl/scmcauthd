CREATE USER scmcauthd;

GRANT SELECT ON "users_priv", "privileges", "users", "groups", "role_privileges", "user_roles" TO "scmcauthd";

GRANT SELECT, INSERT ON "session_log" TO "scmcauthd";
GRANT UPDATE (client_agent, logout, logout_reason) ON session_log TO scmcauthd;
GRANT SELECT, USAGE ON "session_log_id_seq" TO "scmcauthd";
