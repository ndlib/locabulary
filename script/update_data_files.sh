#!/bin/bash

echo "Updating Administrative Units"
ruby script/google_spreadsheet.rb "1oBW5FCTtYXsUi8roBiMRBLFY3dXamhTqy-kiG2rqu5Q" "data/administrative_units.json"
