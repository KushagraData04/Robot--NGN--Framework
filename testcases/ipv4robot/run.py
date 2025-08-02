import subprocess

# Replace with your actual robot file paths
robot_files = ["ipv4_physical.robot", "ipv4_physical_cleanup.robot"]

for i in range(1000):
    print(f"Run {i+1} of 1000")
    for file in robot_files:
        result = subprocess.run(["robot", file])
        if result.returncode != 0:
            print(f"Failure in {file} on iteration {i+1}")