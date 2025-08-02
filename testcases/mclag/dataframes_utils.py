import pandas as pd

def compare_dataframes(df1, df2):
    """
    Compares two dataframes and returns a message with the result.
    """
    if df1.equals(df2):
        return "DataFrames are equal"
    else:
        # Get differences as a report (optional, can customize as needed)
        difference_report = pd.concat([df1, df2]).drop_duplicates(keep=False)
        return f"DataFrames are not equal:\n{difference_report}"

# Splitting data into lines and initializing an empty list for entries
def parse_fdb_entries(data_string):
      # Splitting data into lines and initializing an empty list for entries
      lines = data_string.strip().splitlines()[6:]  # Skip header row
      fdb_entries = []
  
  
      print("******************** Start of fdb entries **********************")
      for line in lines:
          #print(line)
          parts = line.split()
          entry = {
              "No": int(parts[0]),
              "TYPE": parts[1],
              "MAC": parts[2],
              "VID": int(parts[3]),
              "DEV": parts[4],
              "ORIGIN-DEV": parts[5],
              "AGE": parts[6] if len(parts) > 6 else ""
          }
          fdb_entries.append(entry)
          #Print extracted entries for verification
      for entry in fdb_entries:
          print(entry)
  
      print("******************** End of fdb entries **********************")
      return fdb_entries

def compare_fdb_entries(fdb_entries_lxc1, fdb_entries_lxc2):
   # Find entries in fdb_entries_lxc1 that are not in fdb_entries_lxc2
   unique_entries_lxc1 = [entry for entry in fdb_entries_lxc1 if not any(
     entry["MAC"] == other["MAC"] and
     entry["VID"] == other["VID"] and
     entry["DEV"] == other["DEV"] and
     entry["AGE"] != other ["AGE"] for other in fdb_entries_lxc2)]
 
   # Find entries in fdb_entries_lxc2 that are not in fdb_entries_lxc1
   unique_entries_lxc2 = [entry for entry in fdb_entries_lxc2 if not any(
     entry["MAC"] == other["MAC"] and
     entry["VID"] == other["VID"] and
     entry["DEV"] == other["DEV"] and
     entry["AGE"] != other ["AGE"] for other in fdb_entries_lxc1)]
 
 
   # Print the results
   print("Unique Entries lxc1:", unique_entries_lxc1)
   print("Unique Entries lxc2:", unique_entries_lxc2)

   if not unique_entries_lxc1 and not unique_entries_lxc2:
     return "PASS"
   else :
     return "FAIL"

def parse_arp_entries(data_string):
      # Splitting data into lines and initializing an empty list for entries
      lines = data_string.strip().splitlines()[5:]  # Skip header row
      arp_entries = []
  
  
      print("******************** Start of arp entries **********************")
      for line in lines:
          #print(line)
          parts = line.split()
          entry = {
              "No": int(parts[0]),
              "IP": parts[1],
              "MAC": parts[2],
              "DEV": parts[3],
              "PERM": parts[4]
          }
          arp_entries.append(entry)
          #Print extracted entries for verification
      for entry in arp_entries:
          print(entry)
  
      print("******************** End of arp entries **********************")
      return arp_entries

def compare_arp_entries(arp_entries_lxc1, arp_entries_lxc2):
   # Find entries in fdb_entries_lxc1 that are not in fdb_entries_lxc2
   unique_entries_lxc1 = [entry for entry in arp_entries_lxc1 if not any(
     entry["IP"] == other["IP"] and
     entry["MAC"] == other["MAC"] and
     entry["DEV"] == other["DEV"] and
     entry["PERM"] == other ["PERM"] for other in arp_entries_lxc2)]
 
   # Find entries in fdb_entries_lxc2 that are not in fdb_entries_lxc1
   unique_entries_lxc2 = [entry for entry in arp_entries_lxc2 if not any(
     entry["IP"] == other["IP"] and
     entry["MAC"] == other["MAC"] and
     entry["DEV"] == other["DEV"] and
     entry["PERM"] == other ["PERM"] for other in arp_entries_lxc1)]
 
 
   # Print the results
   print("Unique Entries lxc1:", unique_entries_lxc1)
   print("Unique Entries lxc2:", unique_entries_lxc2)

   if not unique_entries_lxc1 and not unique_entries_lxc2:
     return "PASS"
   else :
     return "FAIL"

def parse_nd_entries(data_string):
      # Splitting data into lines and initializing an empty list for entries
      lines = data_string.strip().splitlines()[5:]  # Skip header row
      nd_entries = []
  
  
      print("******************** Start of nd entries **********************")
      for line in lines:
          #print(line)
          parts = line.split()
          entry = {
              "No": int(parts[0]),
              "IPv6": parts[1],
              "MAC": parts[2],
              "DEV": parts[3],
              "PERM": parts[4]
          }
          nd_entries.append(entry)
          #Print extracted entries for verification
      for entry in nd_entries:
          print(entry)
  
      print("******************** End of nd entries **********************")
      return nd_entries

def compare_nd_entries(nd_entries_lxc1, nd_entries_lxc2):
   # Find entries in fdb_entries_lxc1 that are not in fdb_entries_lxc2
   unique_entries_lxc1 = [entry for entry in nd_entries_lxc1 if not any(
     entry["IPv6"] == other["IPv6"] and
     entry["MAC"] == other["MAC"] and
     entry["DEV"] == other["DEV"] and
     entry["PERM"] == other ["PERM"] for other in nd_entries_lxc2)]
 
   # Find entries in fdb_entries_lxc2 that are not in fdb_entries_lxc1
   unique_entries_lxc2 = [entry for entry in nd_entries_lxc2 if not any(
     entry["IPv6"] == other["IPv6"] and
     entry["MAC"] == other["MAC"] and
     entry["DEV"] == other["DEV"] and
     entry["PERM"] == other ["PERM"] for other in nd_entries_lxc1)]
 
 
   # Print the results
   print("Unique Entries lxc1:", unique_entries_lxc1)
   print("Unique Entries lxc2:", unique_entries_lxc2)

   if not unique_entries_lxc1 and not unique_entries_lxc2:
     return "PASS"
   else :
     return "FAIL"
