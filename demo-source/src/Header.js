export default function Header() {
	return (<div className = "row header toolbar">
		<div className = "cols">
			<div className = "row start">
				<a href = { process.env.PUBLIC_URL }>
					<img src = "sean-icon.png" alt = "sean" />
				</a>
				<a href = { process.env.PUBLIC_URL }><h1>php-wasm</h1></a>
				<hr />
			</div>
		</div>
		<div className = "separator">
		</div>
	</div>);
};
