Module.preRun = Module.preRun || [];
if (typeof Module.preRun == 'function') Module.preRun = [ Module.preRun ];
Module.preRun.push(() => ENV.ICU_DATA = ENV.ICU_DATA || '/preload');
