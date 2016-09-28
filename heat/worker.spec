{
  'properties':{
    'name': 'worker',
    'template': 'work.yaml',
    'context': {
       'region_name': 'RegionOne',
    },
    'disable_rollback': true,
  },
  'type': 'os.heat.stack',
  'version': 1.0,
}
