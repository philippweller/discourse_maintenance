import { apiInitializer } from "discourse/lib/api";
import Wartungsbanner from "../components/wartungsbanner";

export default apiInitializer("1.8.0", (api) => {
  api.renderInOutlet("above-site-header", Wartungsbanner);
});
