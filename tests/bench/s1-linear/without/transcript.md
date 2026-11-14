# Previous session transcript: ledger-api release pipeline

USER: We need a release pipeline for ledger-api. It is a Node service with a Postgres database. Let's define the steps first and the details after.

ASSISTANT: A common order is: 1) build, 2) run tests, 3) run database migrations, 4) deploy, 5) smoke test. Do you want staging and production to share the same pipeline?

USER: Yes, same pipeline, different targets. Staging goes to region eu-west-1. Keep the order you proposed for now.

ASSISTANT: Noted. Steps: build, test, migrate, deploy, smoke test. Staging in eu-west-1. Which port does the service listen on?

USER: 8080. And we also need to pick a logging library before we wire the pipeline, because the smoke test checks the log output format.

ASSISTANT: Two good options: winston (very flexible, many transports) and pino (structured JSON, very low overhead). For a service with high request volume, pino is usually the better fit.

USER: Let me think about it. What about the Docker base image?

ASSISTANT: node:22-alpine keeps the image small. If you rely on native modules, node:22-slim avoids musl issues.

USER: We use bcrypt, which is native. Go with slim.

ASSISTANT: node:22-slim then. I will assume a multi-stage build: dependencies in one stage, runtime in another.

USER: Fine. Back to logging: we benchmarked both last week. Winston added about 9 ms per request at peak, pino about 1 ms. We go with pino, performance is the deciding factor. Winston is rejected.

ASSISTANT: Decision recorded: pino, because of lower overhead (about 1 ms vs 9 ms per request). The smoke test will parse JSON lines.

USER: Rollback policy: keep the last 3 releases available so we can roll back instantly.

ASSISTANT: OK, retain 3 releases. Do you want automatic rollback when the smoke test fails?

USER: Yes, automatic rollback on smoke test failure.

ASSISTANT: Added. Smoke test failure triggers rollback to the previous release.

USER: Wait, there is a problem with the order. Our integration tests run against a real schema, so migrations must run before the tests, not after.

ASSISTANT: Good catch. New order: 1) build, 2) migrate, 3) test, 4) deploy, 5) smoke test.

USER: Also, the metrics agent on our hosts already uses port 8080. Move the service to 9090.

ASSISTANT: Port changed from 8080 to 9090 because the metrics agent occupies 8080. I will update the health check URL accordingly.

USER: What health check path do you suggest?

ASSISTANT: /healthz returning 200 with a small JSON body, and /readyz checking the database connection.

USER: Good, use both. Now, after the smoke test passes we must notify the team in the #releases channel.

ASSISTANT: Added step 6: notify #releases after a successful smoke test. Order: build, migrate, test, deploy, smoke test, notify.

USER: How long should the smoke test wait for the service to become ready?

ASSISTANT: Poll /readyz every 5 seconds with a 120 second timeout.

USER: OK. Production region?

ASSISTANT: Not defined yet. Same as staging?

USER: No, production goes to eu-central-1 for data residency reasons.

ASSISTANT: Production: eu-central-1. Staging stays in eu-west-1.

USER: About rollback: 3 releases is too few, compliance asked for 5. Change it.

ASSISTANT: Retention changed from 3 to 5 releases.

USER: Last thing: should migrations be reversible?

ASSISTANT: Yes, every migration should ship a down script, otherwise automatic rollback can leave the schema ahead of the code.

USER: Agreed, make down scripts mandatory. That's all for today.

ASSISTANT: Summary saved. We will continue with the CI configuration next session.
