const https = require('https');
const namespace = process.env.NAMESPACE;
const token = process.env.KUBE_TOKEN;
const host = process.env.KUBERNETES_SERVICE_HOST;
const port = process.env.KUBERNETES_PORT_443_TCP_PORT;

const defaultOptions = function (path, headers) {
	const options = {
		hostname: host,
		port: port,
		path: path,
		agent: false,
		headers: headers || {}
	};
	options.headers.Authorization = `Bearer ${token}`;
	return options;
};

const get = function (path, headers) {
	const options = defaultOptions(path, headers);
	https.get(options, (res) => {
		console.log('statusCode:', res.statusCode);
		console.log('headers:', res.headers);
		res.on('data', (d) => {
			process.stdout.write(d);
		});
	}).on('error', (e) => {
		console.error(e);
	});
};

get(`apis/apps/v1/namespaces/${namespace}/deployments/bulletin-board-deployment`);
