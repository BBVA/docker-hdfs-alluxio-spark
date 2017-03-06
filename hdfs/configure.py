#!/usr/bin/env python

import xml.etree.cElementTree as ET
import sys

doc = ET.parse(sys.argv[1])

root = doc.getroot()
    

prop  = ET.Element('property')
p_name = ET.SubElement(prop,'name' )
p_value = ET.SubElement(prop,'value' )
p_name.text = sys.argv[2]
p_value.text = sys.argv[3]

root.append(prop)
	
doc.write(sys.argv[1],xml_declaration=True)

