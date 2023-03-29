#!/usr/bin/env python
# https://chat.openai.com/chat/42717af4-33c0-425d-8487-781bd753b5c3 
import os
from g_sorcery.ebuild import Ebuild
from g_sorcery.package import Package
from g_sorcery.version import Version

# Define some variables for the ebuild
pkgname = input("Enter the package name: ")
ebuild_path = input("Enter the path to the ebuild directory: ")
go_versions = [">=1.16"]
# Define some variables for the ebuild
pkgname = input("Enter the package name: ")
ebuild_path = input("Enter the path to the ebuild directory: ")
maintainer = input("Enter the PKG-Maintainer/Your Email: ")
homepage = input("Enter the package Homepage-URL ")
ebuild.src_uri = input("Enter the package Homepage-URL ")
pkg-license = input("Enter the package license Type IE: MIT GPL etc.. ")
# Prompt the user for the package description and store it in a variable
pkg_description = input("Enter the package description: ")

# Use the variable to set the ebuild description field for g-sourcey compat. 
ebuild.description = pkg_description
ebuild.license = "pkg-license"

# Use the G-Sorcery library to obtain the package's version
try:
    package = Package(pkgname)
    latest_version = package.latest_version()
    version = Version(latest_version)
    pkgver = version.version
except Exception as e:
    print(f"Failed to obtain version for {pkgname}: {str(e)}")
    exit(1)

# Create the ebuild directory if it doesn't exist
if not os.path.exists(ebuild_path):
    os.makedirs(ebuild_path)

# Create the ebuild file using the g_sorcery library
ebuild = Ebuild(pkgname, pkgver, maintainer=maintainer, homepage=homepage)
ebuild.inherit( "go-module")
ebuild.description = input("Enter the package description: ")
ebuild.src_uri = f"https://www.example.com/{pkgname}-{pkgver}.tar.gz"
for go_version in go_versions:
    ebuild.depend(f"dev-lang/go:{go_version}")
ebuild.slot = "0"
ebuild.license = "MIT"
ebuild.iuse = ""
ebuild.s = f"${{WORKDIR}}/{pkgname}-${{PV}}"
ebuild.install.append("emake")
ebuild.install.append("default")
ebuild.test.append("emake test")

# Write the ebuild to a file
with open(os.path.join(ebuild_path, f"{pkgname}-{pkgver}.ebuild"), "w") as f:
    f.write(str(ebuild))

# Make the ebuild executable
os.chmod(os.path.join(ebuild_path, f"{pkgname}-{pkgver}.ebuild"), 0o755)

# Print a message indicating that the ebuild has been generated
print(f"Ebuild for {pkgname}-{pkgver} has been generated in {ebuild_path}")
