################################################################################
# get_enterprise_url.py                                                        #
# gets the URL to download Vault Enterprise or Consul Enterprise               #
################################################################################
import sys
import json
import urllib
import urllib2
import semver

def get_latest_version(product):
    # use semver's cmp function as the sort function to get the latest version
    jsondata = json.loads(urllib2.urlopen("https://releases.hashicorp.com/%s/index.json" % product).read())
    return sorted(jsondata['versions'].keys(), cmp=lambda a, b: semver.cmp(a, b))[-1]

def get_version_url(product, platform, os, version):
    # hacky encoding stuff to insert a URL entity so the Python string formatter does not misinterpret the token
    return "https://s3-us-west-2.amazonaws.com/hc-enterprise-binaries/%s/ent/%s/%s-enterprise_%s%sent_%s_%s.zip" % (product, version, product, version, urllib.quote_plus('+'), os, platform)

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--product", help="Name of the product ('vault' or 'consul')")
    parser.add_argument("-l", "--platform", default="amd64", help="Defaults to amd64. Replace with desired architecture")
    parser.add_argument("-o", "--os", default="linux", help="Defaults to linux. Replace with desired operating system")
    parser.add_argument("-v", "--version", default="latest", help="Defaults to latest. Replace with desired version")
    args = parser.parse_args()

    product, platform, os = args.product, args.platform, args.os
    version = get_latest_version(product).replace('+ent', '') if args.version == 'latest' else args.version
    print get_version_url(product, platform, os, version)
