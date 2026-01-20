class GlobalState {
  isVip: boolean;
  _listeners: ((isVip: boolean) => void)[];

  constructor() {
    this.isVip = false;
    this._listeners = []; // Initialize in constructor
  }

  // Emit isVip change event
  emitIsVipChange(isVip: boolean) {
    this.isVip = isVip;
    // Defensive check to ensure _listeners is an array
    if (this._listeners) {
      this._listeners.forEach(callback => callback(isVip));
    } else {
      console.log('Warning: _listeners is undefined, initializing now');
      this._listeners = [];
    }
  }

  // Subscribe to isVip changes
  onIsVipChange(callback: (isVip: boolean) => void) {
    // Ensure _listeners is an array
    if (!this._listeners) {
      this._listeners = [];
    }
    this._listeners.push(callback);
    // Return unsubscribe function
    return () => {
      this._listeners = this._listeners.filter(cb => cb !== callback);
    };
  }
}

// Export singleton instance
export const globalStates = new GlobalState();