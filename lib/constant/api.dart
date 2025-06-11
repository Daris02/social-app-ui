const host = '192.168.8.100'; // 192.168.8.100:4000;

const env = 'dev';

const baseApiUrlLocal = 'http://$host:4000';
const baseApiUrlProd = 'https://$host';

const baseApiUrl = env == 'dev' ? baseApiUrlLocal : baseApiUrlProd;

const baseWSUrlLocal = 'ws://$host';
const baseWSUrlProd = 'wss://$host';

const baseWSUrl = env == 'dev' ? baseWSUrlLocal : baseWSUrlProd;
