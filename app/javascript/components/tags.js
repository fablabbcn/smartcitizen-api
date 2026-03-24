import Tags from "bootstrap5-tags";

export function setupTags(selector) {
    Tags.init(selector || ".tag-select", {
      baseClass: "tags-badge badge bg-light border text-dark text-truncate p-2 rounded-4"
    });
}
