🚀 RHCSA Real-World Lab: Automated Web Service Deployment with Podman
🏆 Objective
You will:

Deploy a containerized web service (nginx, because it's small and universal) using Podman.

Serve a static page from a custom directory.

Bind-mount the content from your host (simulate a “production” update).

Automate starting and stopping the container with scripts.

Handle SELinux file context for persistent data.

Prove it's working and clean up safely.

🌐 Scenario
You’re a sysadmin. A developer hands you a new static website in /srv/testsite.
Management wants it running in a container for isolation—but the files should stay on the host so they can be updated without rebuilding the image.

You must:

Launch an nginx container with Podman,

Mount /srv/testsite into the container as read-only,

Serve the site on port 8443 (or another port if you want, since 8443 is busy),

Automate startup/shutdown,

Handle SELinux so the container can read the files.

🛠️ Step 1: Prepare Host Content
Make sure /srv/testsite contains at least an index.html (you already do).

🛠️ Step 2: Fix SELinux Context for Podman
Containers use a special label (container_file_t) for mounted host directories.

sudo chcon -Rt container_file_t /srv/testsite
Context:

This allows Podman/containers to access the files without turning off SELinux.

If you skip this step, the container will fail with "permission denied".

🛠️ Step 3: Create a Podman Run Script
Let’s call it run_testsite_container.sh:

#!/bin/bash
# Start an nginx container to serve /srv/testsite on port 8081

CONTAINER_NAME=testsite-nginx

podman run -d \
    --name $CONTAINER_NAME \
    -p 8081:80 \
    -v /srv/testsite:/usr/share/nginx/html:ro,Z \
    nginx:alpine
-d = detached

--name = easier management

-p 8081:80 = maps host 8081 to container 80 (change if needed)

-v /srv/testsite:/usr/share/nginx/html:ro,Z = mounts your host dir read-only; :Z relabels for SELinux container access (use with or instead of chcon above)

nginx:alpine = lightweight, fast

Make it executable:

chmod +x run_testsite_container.sh
🛠️ Step 4: Create a Shutdown Script
Let’s call it stop_testsite_container.sh:

#!/bin/bash
# Stop and remove the testsite-nginx container

CONTAINER_NAME=testsite-nginx

podman stop $CONTAINER_NAME
podman rm $CONTAINER_NAME
Make it executable:

chmod +x stop_testsite_container.sh
🛠️ Step 5: Test It All
Start the container:

./run_testsite_container.sh
Test access (from host):

curl http://localhost:8081
You should see your /srv/testsite/index.html content.

Update the page:

echo "Updated at $(date)" | sudo tee /srv/testsite/index.html
curl http://localhost:8081
Change is instant—no need to restart or rebuild the container.

Stop the container:

./stop_testsite_container.sh
Confirm it’s down:

podman ps
# Should show nothing running
🦾 Lab Context and Best Practices
Why use :ro,Z and chcon?

Both ensure SELinux isn’t blocking the container.

:Z tells Podman to set the right SELinux context automatically (most modern Podman installs). chcon is manual, but both can be used.

Why bind-mount instead of COPY?

You want to allow live updates to static files without rebuilding the container.

Why automate with scripts?

RHCSA wants you to show basic shell scripting, automation, and repeatable tasks. Real world: No one runs podman run by hand in prod.

What’s the value of containerizing?

No web server dependencies on host.

Nginx runs in isolation, can be started/stopped/tested with zero risk to your main Apache/SSL setup.

🧩 Bonus Lab Extensions
Convert to a systemd service (for auto-start on boot).

Add firewall rules (if you want LAN access).

Use podman generate systemd for production-readiness.

📝 Lab Recap—What You’ve Demonstrated
Podman usage, automation, SELinux context management.

Clean start/stop workflow.

Real-world “dev/prod handoff” for static site hosting in a container.
