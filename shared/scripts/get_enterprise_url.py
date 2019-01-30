import sys
import json
import urllib
import urllib2
import semver

def get_latest_version(product):
    jsondata = json.loads(urllib2.urlopen("https://releases.hashicorp.com/%s/index.json" % product).read())
    return sorted(jsondata['versions'].keys(), cmp=lambda a, b: semver.cmp(a, b))[-1]

def get_version_url(product, platform, os, version):
    return "https://s3-us-west-2.amazonaws.com/hc-enterprise-binaries/%s/ent/%s/%s-enterprise_%s%sent_%s_%s.zip" % (product, version, product, version, urllib.quote_plus('+'), os, platform)

if __name__ == '__main__':
    try:
        product, platform, os = sys.argv[1:]
        v = get_latest_version(product).replace('+ent', '')
        print get_version_url(product, platform, os, v)
    except ValueError:
        print "Usage: %s [product] [platform] [os]" % sys.argv[0]
