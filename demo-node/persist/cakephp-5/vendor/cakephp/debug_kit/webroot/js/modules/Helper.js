export default (() => {
  const isLocalStorageAvailable = () => {
    if (!window.localStorage) {
      return false;
    }
    try {
      window.localStorage.setItem('testKey', '1');
      window.localStorage.removeItem('testKey');
      return true;
    } catch (error) {
      return false;
    }
  };

  return {
    isLocalStorageAvailable,
  };
})();
